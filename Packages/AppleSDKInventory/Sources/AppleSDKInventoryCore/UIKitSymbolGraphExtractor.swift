import Foundation
import CatalogModel

// MARK: - Symbol Graph Intermediate Decodable Types

private struct SymbolGraphFile: Decodable {
    struct Module: Decodable {
        let name: String
    }
    struct SymbolIdentifier: Decodable {
        let precise: String
        let interfaceLanguage: String?
    }
    struct Names: Decodable {
        let title: String
        let subHeading: [Fragment]?
    }
    struct Fragment: Decodable {
        let kind: String
        let spelling: String
    }
    struct Kind: Decodable {
        let identifier: String
        let displayName: String?
    }
    struct Version: Decodable {
        let major: Int?
        let minor: Int?
        let patch: Int?

        var osVersion: OSVersion? {
            guard let major else { return nil }
            return OSVersion(major, minor ?? 0, patch ?? 0)
        }
    }
    struct AvailabilityItem: Decodable {
        let domain: String?
        let introduced: Version?
        let deprecated: Version?
        let obsoleted: Version?
        let message: String?
        let renamed: String?
        let isUnconditionallyDeprecated: Bool?
        let isUnconditionallyUnavailable: Bool?
    }
    struct Symbol: Decodable {
        let identifier: SymbolIdentifier
        let names: Names
        let pathComponents: [String]
        let kind: Kind
        let declarationFragments: [Fragment]?
        let accessLevel: String?
        let availability: [AvailabilityItem]?
    }
    struct Relationship: Decodable {
        let kind: String
        let source: String
        let target: String
        let targetFallback: String?
    }

    let module: Module
    let symbols: [Symbol]
    let relationships: [Relationship]
}

// MARK: - Extractor

public enum UIKitSymbolGraphExtractor {
    public static func extract(from directory: URL) throws -> [SDKDeclaration] {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        let jsonFiles = contents.filter { $0.pathExtension == "json" && $0.lastPathComponent.contains("symbols") }

        var rawSymbols: [String: SymbolGraphFile.Symbol] = [:]
        var parentOf: [String: String] = [:] // member precise ID -> parent precise ID
        var superclassOf: [String: String] = [:] // class precise ID -> superclass name
        var conformancesOf: [String: Set<String>] = [:] // type precise ID -> set of protocols

        for file in jsonFiles {
            let data = try Data(contentsOf: file)
            let decoded = try JSONDecoder().decode(SymbolGraphFile.self, from: data)
            for symbol in decoded.symbols {
                rawSymbols[symbol.identifier.precise] = symbol
            }
            for rel in decoded.relationships {
                switch rel.kind {
                case "memberOf":
                    parentOf[rel.source] = rel.target
                case "inheritsFrom":
                    if let targetSymbol = rawSymbols[rel.target] {
                        superclassOf[rel.source] = targetSymbol.names.title
                    } else if let fallback = rel.targetFallback {
                        superclassOf[rel.source] = fallback
                    }
                case "conformsTo":
                    let protoName = rawSymbols[rel.target]?.names.title ?? rel.targetFallback
                    if let protoName {
                        conformancesOf[rel.source, default: []].insert(protoName)
                    }
                default:
                    break
                }
            }
        }

        // Separate types from members
        var typePreciseIDs: Set<String> = []
        var membersByParent: [String: [SymbolGraphFile.Symbol]] = [:]

        for (precise, symbol) in rawSymbols {
            guard isPublicOrOpen(symbol.accessLevel) else { continue }
            if isTypeKind(symbol.kind.identifier) {
                typePreciseIDs.insert(precise)
            } else if isMemberKind(symbol.kind.identifier) {
                // Find parent: either explicit relationship or derived from pathComponents
                if let parentPrecise = parentOf[precise] {
                    membersByParent[parentPrecise, default: []].append(symbol)
                } else if symbol.pathComponents.count > 1 {
                    // Try finding parent by path
                    let parentPath = Array(symbol.pathComponents.dropLast())
                    if let parentSymbol = rawSymbols.values.first(where: { $0.pathComponents == parentPath }) {
                        membersByParent[parentSymbol.identifier.precise, default: []].append(symbol)
                    }
                }
            }
        }

        // Construct SDKDeclaration for each type
        var declarations: [SDKDeclaration] = []

        for precise in typePreciseIDs {
            guard let symbol = rawSymbols[precise] else { continue }
            let title = symbol.names.title
            let qualified = symbol.pathComponents.joined(separator: ".")
            let kind = mapSymbolKind(symbol.kind.identifier)
            let availability = mapAvailability(symbol.availability)
            let visibility: SymbolVisibility = symbol.pathComponents.contains(where: { $0.hasPrefix("_") }) ? .underscored : .public

            var members: [SDKMember] = []
            var signatures: [SDKSignature] = []
            var enumCases: [String] = []

            for memberSym in membersByParent[precise] ?? [] {
                let memberDeclString = memberSym.declarationFragments?.map(\.spelling).joined() ?? memberSym.names.title
                let memberAvail = mapAvailability(memberSym.availability)

                if memberSym.kind.identifier == "swift.init" {
                    signatures.append(.init(
                        declaration: memberDeclString,
                        availability: memberAvail
                    ))
                } else if memberSym.kind.identifier == "swift.enum.case" {
                    enumCases.append(memberSym.names.title)
                } else {
                    let memKind = mapMemberKind(memberSym.kind.identifier)
                    members.append(.init(
                        name: memberSym.names.title,
                        kind: memKind,
                        declaration: memberDeclString,
                        availability: memberAvail
                    ))
                }
            }

            let superclass = superclassOf[precise]
            let conformances = Array(conformancesOf[precise] ?? []).sorted()

            declarations.append(.init(
                id: "UIKit.\(qualified)",
                framework: .uiKit,
                module: "UIKit",
                symbol: title,
                qualifiedName: qualified,
                kind: kind,
                origin: .objectiveC,
                visibility: visibility,
                availability: availability,
                superclass: superclass,
                conformances: conformances,
                signatures: signatures.sorted { $0.declaration < $1.declaration },
                members: members.sorted { ($0.kind.rawValue, $0.name) < ($1.kind.rawValue, $1.name) },
                enumCases: enumCases.sorted(),
                preciseIdentifier: precise
            ))
        }

        return declarations.sorted { ($0.qualifiedName, $0.kind.rawValue) < ($1.qualifiedName, $1.kind.rawValue) }
    }

    private static func isPublicOrOpen(_ access: String?) -> Bool {
        guard let access else { return true }
        return access == "public" || access == "open"
    }

    private static func isTypeKind(_ kind: String) -> Bool {
        switch kind {
        case "swift.class", "swift.struct", "swift.enum", "swift.protocol", "swift.typealias", "swift.actor":
            return true
        default:
            return false
        }
    }

    private static func isMemberKind(_ kind: String) -> Bool {
        switch kind {
        case "swift.init", "swift.method", "swift.type.method", "swift.property", "swift.type.property",
             "swift.subscript", "swift.enum.case":
            return true
        default:
            return false
        }
    }

    private static func mapSymbolKind(_ kind: String) -> SymbolKind {
        switch kind {
        case "swift.class": return .classType
        case "swift.struct": return .structure
        case "swift.enum": return .enumeration
        case "swift.protocol": return .protocolType
        case "swift.typealias": return .typeAlias
        case "swift.actor": return .actor
        default: return .structure
        }
    }

    private static func mapMemberKind(_ kind: String) -> MemberKind {
        switch kind {
        case "swift.init": return .initializer
        case "swift.method": return .method
        case "swift.type.method": return .typeMethod
        case "swift.property": return .property
        case "swift.type.property": return .typeProperty
        case "swift.subscript": return .subscript
        case "swift.enum.case": return .enumCase
        default: return .method
        }
    }

    private static func mapAvailability(_ list: [SymbolGraphFile.AvailabilityItem]?) -> CatalogAvailability {
        guard let list else { return .init() }
        var result = CatalogAvailability()
        for item in list {
            guard item.domain == "iOS" || item.domain == "*" || item.domain == nil else { continue }
            if let introduced = item.introduced?.osVersion {
                result.introduced = introduced
            }
            if let deprecated = item.deprecated?.osVersion {
                result.deprecated = deprecated
                result.isDeprecated = true
            }
            if let obsoleted = item.obsoleted?.osVersion {
                result.obsoleted = obsoleted
            }
            if item.isUnconditionallyDeprecated == true {
                result.isDeprecated = true
            }
            if item.isUnconditionallyUnavailable == true {
                result.isUnavailable = true
            }
            if let message = item.message { result.message = message }
            if let renamed = item.renamed { result.renamed = renamed }
        }
        return result
    }
}
