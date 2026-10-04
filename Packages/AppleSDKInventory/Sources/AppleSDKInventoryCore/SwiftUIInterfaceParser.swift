import Foundation
import SwiftParser
import SwiftParserDiagnostics
import SwiftSyntax
import CatalogModel

public struct SwiftInterfaceInput: Sendable {
    public var module: String
    public var url: URL

    public init(module: String, url: URL) {
        self.module = module
        self.url = url
    }
}

public enum SwiftUIInterfaceParser {
    public static func parse(_ input: SwiftInterfaceInput) throws -> (
        identity: SDKSourceFileIdentity,
        declarations: [SDKDeclaration]
    ) {
        let data = try Data(contentsOf: input.url)
        guard let source = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadInapplicableStringEncoding)
        }
        let syntax = Parser.parse(source: source)
        let diagnostics = ParseDiagnosticsGenerator.diagnostics(for: syntax)
        guard diagnostics.isEmpty else {
            let summary = diagnostics.prefix(10).map(\.message).joined(separator: "; ")
            throw NSError(
                domain: "AppleSDKInventory",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Swift parser diagnostics in \(input.url.path): \(summary)"]
            )
        }
        let visitor = SwiftUIInventoryVisitor(module: input.module)
        visitor.walk(syntax)
        return (
            .init(module: input.module, fileName: input.url.lastPathComponent, sha256: SHA256.hexDigest(data)),
            visitor.declarations
        )
    }
}

private final class SwiftUIInventoryVisitor: SyntaxVisitor {
    let module: String
    var declarations: [SDKDeclaration] = []
    private var typeScope: [String] = []
    private var viewExtensionAvailability: [[String]] = []
    private var typeExtensionDepths: [Int] = []
    private var typeExtensionAvailability: [[String]] = []

    init(module: String) {
        self.module = module
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        recordType(
            name: node.name.text,
            kind: .structure,
            modifiers: node.modifiers,
            attributes: node.attributes,
            generics: node.genericParameterClause,
            inheritance: node.inheritanceClause,
            members: node.memberBlock.members
        )
        typeScope.append(node.name.text)
        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        typeScope.removeLast()
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        recordType(
            name: node.name.text,
            kind: .classType,
            modifiers: node.modifiers,
            attributes: node.attributes,
            generics: node.genericParameterClause,
            inheritance: node.inheritanceClause,
            members: node.memberBlock.members
        )
        typeScope.append(node.name.text)
        return .visitChildren
    }

    override func visitPost(_ node: ClassDeclSyntax) {
        typeScope.removeLast()
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        recordType(
            name: node.name.text,
            kind: .enumeration,
            modifiers: node.modifiers,
            attributes: node.attributes,
            generics: node.genericParameterClause,
            inheritance: node.inheritanceClause,
            members: node.memberBlock.members
        )
        typeScope.append(node.name.text)
        return .visitChildren
    }

    override func visitPost(_ node: EnumDeclSyntax) {
        typeScope.removeLast()
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        if isPublic(node.modifiers) {
            let symbol = qualified(node.name.text)
            let rawAvail = availability(node.attributes)
            let parsedAvail = parseAvailability(rawAvail)
            declarations.append(.init(
                id: "\(module).\(symbol)",
                framework: .swiftUI,
                module: module,
                symbol: symbol,
                qualifiedName: symbol,
                kind: .protocolType,
                origin: .swift,
                visibility: sdkVisibility(symbol: symbol, attributes: node.attributes),
                availability: parsedAvail,
                rawAvailability: rawAvail,
                attributes: attributeList(node.attributes),
                genericParameters: node.primaryAssociatedTypeClause?.primaryAssociatedTypes.map(\.name.text) ?? [],
                conformances: node.inheritanceClause?.inheritedTypes.map { normalizedQualifiedName($0.type.trimmedDescription) } ?? []
            ))
        }
        typeScope.append(node.name.text)
        return isPublic(node.modifiers) ? .visitChildren : .skipChildren
    }

    override func visitPost(_ node: ProtocolDeclSyntax) {
        typeScope.removeLast()
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        let extended = normalizedQualifiedName(node.extendedType.trimmedDescription)
        if extended == "View" || extended.hasSuffix(".View") {
            viewExtensionAvailability.append(availability(node.attributes))
            typeExtensionDepths.append(0)
            typeExtensionAvailability.append([])
            return .visitChildren
        }
        var components = extended.split(separator: ".").map(String.init)
        if components.first == module { components.removeFirst() }
        typeScope.append(contentsOf: components)
        typeExtensionDepths.append(components.count)
        typeExtensionAvailability.append(availability(node.attributes))
        return .visitChildren
    }

    override func visitPost(_ node: ExtensionDeclSyntax) {
        let extended = normalizedQualifiedName(node.extendedType.trimmedDescription)
        if extended == "View" || extended.hasSuffix(".View") {
            viewExtensionAvailability.removeLast()
        }
        let depth = typeExtensionDepths.removeLast()
        if depth > 0 { typeScope.removeLast(depth) }
        typeExtensionAvailability.removeLast()
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard !viewExtensionAvailability.isEmpty, typeScope.isEmpty, isPublic(node.modifiers) else {
            return .visitChildren
        }
        let signature = makeSignature(
            node.name.text,
            signature: node.signature,
            generics: node.genericParameterClause?.parameters.map(\.name.text) ?? [],
            attributes: node.attributes
        )
        let rawAvail = viewExtensionAvailability.flatMap { $0 } + availability(node.attributes)
        let parsedAvail = parseAvailability(rawAvail)
        let symbol = node.name.text
        declarations.append(.init(
            id: "\(module).View.\(symbol)",
            framework: .swiftUI,
            module: module,
            symbol: symbol,
            qualifiedName: "View.\(symbol)",
            kind: .modifier,
            origin: .swift,
            visibility: sdkVisibility(symbol: symbol, attributes: node.attributes),
            availability: parsedAvail,
            rawAvailability: rawAvail,
            attributes: attributeList(node.attributes),
            genericParameters: signature.genericParameters,
            signatures: [signature]
        ))
        return .skipChildren
    }

    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        guard !typeScope.isEmpty, isPublic(node.modifiers) else { return .skipChildren }
        let symbol = typeScope.joined(separator: ".")
        let declaration = declarations.last(where: { $0.symbol == symbol })
            ?? SDKDeclaration(
                id: "\(module).\(symbol)",
                framework: .swiftUI,
                module: module,
                symbol: symbol,
                qualifiedName: symbol,
                kind: .structure
            )
        let signature = makeSignature(
            "init",
            signature: node.signature,
            generics: node.genericParameterClause?.parameters.map(\.name.text) ?? [],
            attributes: node.attributes
        )
        let rawAvail = declaration.rawAvailability
            + typeExtensionAvailability.flatMap { $0 }
            + availability(node.attributes)
        let parsedAvail = parseAvailability(rawAvail)

        declarations.append(.init(
            id: "\(module).\(symbol)",
            framework: .swiftUI,
            module: module,
            symbol: symbol,
            qualifiedName: symbol,
            kind: declaration.kind,
            origin: .swift,
            visibility: declaration.visibility,
            availability: parsedAvail,
            rawAvailability: rawAvail,
            attributes: declaration.attributes + attributeList(node.attributes),
            genericParameters: declaration.genericParameters,
            conformances: declaration.conformances,
            signatures: [signature]
        ))
        return .skipChildren
    }

    private func recordType(
        name: String,
        kind: SymbolKind,
        modifiers: DeclModifierListSyntax,
        attributes: AttributeListSyntax,
        generics: GenericParameterClauseSyntax?,
        inheritance: InheritanceClauseSyntax?,
        members: MemberBlockItemListSyntax
    ) {
        guard isPublic(modifiers) else { return }
        let conformances = inheritance?.inheritedTypes.map {
            normalizedQualifiedName($0.type.trimmedDescription)
        } ?? []
        let enumCases = members.flatMap { member -> [String] in
            guard let declaration = member.decl.as(EnumCaseDeclSyntax.self) else { return [] }
            return declaration.elements.map(\.name.text)
        }
        let optionSetCases: [String]
        if conformances.contains(where: { $0 == "OptionSet" || $0.hasSuffix(".OptionSet") }) {
            optionSetCases = members.flatMap { member -> [String] in
                guard let declaration = member.decl.as(VariableDeclSyntax.self),
                      isPublic(declaration.modifiers),
                      declaration.modifiers.contains(where: { $0.name.text == "static" }) else {
                    return []
                }
                return declaration.bindings.compactMap { binding in
                    binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                        .trimmingCharacters(in: CharacterSet(charactersIn: "`"))
                }
            }
        } else {
            optionSetCases = []
        }
        let resolvedKind: SymbolKind = conformances.contains(where: {
            $0 == "View" || $0.hasSuffix(".View")
        }) ? .view : kind

        let symbol = qualified(name)
        let rawAvail = availability(attributes)
        let parsedAvail = parseAvailability(rawAvail)

        declarations.append(.init(
            id: "\(module).\(symbol)",
            framework: .swiftUI,
            module: module,
            symbol: symbol,
            qualifiedName: symbol,
            kind: resolvedKind,
            origin: .swift,
            visibility: sdkVisibility(symbol: symbol, attributes: attributes),
            availability: parsedAvail,
            rawAvailability: rawAvail,
            attributes: attributeList(attributes),
            genericParameters: generics?.parameters.map(\.name.text) ?? [],
            conformances: conformances,
            enumCases: enumCases,
            optionSetCases: optionSetCases
        ))
    }

    private func makeSignature(
        _ name: String,
        signature: FunctionSignatureSyntax,
        generics: [String],
        attributes: AttributeListSyntax
    ) -> SDKSignature {
        let parameters = signature.parameterClause.parameters.map { parameter in
            let external = parameter.firstName.text == "_" ? nil : parameter.firstName.text
            let local = parameter.secondName?.text ?? parameter.firstName.text
            let type = normalizedQualifiedName(parameter.type.trimmedDescription)
            let attrs = parameter.attributes.compactMap { element -> String? in
                guard case let .attribute(attribute) = element else { return nil }
                return normalizedQualifiedName(attribute.attributeName.trimmedDescription)
            }
            return SDKParameter(
                label: external,
                name: local == "_" ? "value" : local,
                type: type,
                defaultValue: parameter.defaultValue?.value.trimmedDescription,
                attributes: attrs,
                isBinding: type.contains("Binding<"),
                isViewBuilder: attrs.contains(where: {
                    $0.hasSuffix("ViewBuilder") || $0.hasSuffix("ContentBuilder")
                }),
                isClosure: type.contains("->")
            )
        }
        let returnType = signature.returnClause.map { normalizedQualifiedName($0.type.trimmedDescription) }
        let rawAvail = availability(attributes)
        let parsedAvail = parseAvailability(rawAvail)

        let paramStr = parameters.map { p in
            let lbl = p.label.map { "\($0) " } ?? ""
            let def = p.defaultValue.map { " = \($0)" } ?? ""
            return "\(lbl)\(p.name): \(p.type)\(def)"
        }.joined(separator: ", ")

        var decl = "\(name)(\(paramStr))"
        if let ret = returnType { decl += " -> \(ret)" }

        return .init(
            declaration: decl,
            parameters: parameters,
            returnType: returnType,
            genericParameters: generics,
            isAsync: signature.effectSpecifiers?.asyncSpecifier != nil,
            isThrowing: signature.effectSpecifiers?.throwsClause != nil,
            availability: parsedAvail,
            rawAvailability: rawAvail,
            attributes: attributeList(attributes)
        )
    }

    private func qualified(_ name: String) -> String {
        (typeScope + [name]).joined(separator: ".")
    }

    private func normalizedQualifiedName(_ value: String) -> String {
        value.replacingOccurrences(of: "::", with: ".")
    }

    private func isPublic(_ modifiers: DeclModifierListSyntax) -> Bool {
        modifiers.contains { $0.name.text == "public" || $0.name.text == "open" }
    }

    private func availability(_ attributes: AttributeListSyntax) -> [String] {
        attributes.compactMap { element -> String? in
            guard case let .attribute(attribute) = element,
                  attribute.attributeName.trimmedDescription == "available" else { return nil }
            return attribute.trimmedDescription
        }
    }

    private func attributeList(_ attributes: AttributeListSyntax) -> [String] {
        attributes.compactMap { element -> String? in
            guard case let .attribute(attribute) = element else { return nil }
            return attribute.trimmedDescription
        }
    }

    private func sdkVisibility(symbol: String, attributes: AttributeListSyntax) -> SymbolVisibility {
        if attributeList(attributes).contains(where: { $0.hasPrefix("@_spi") }) { return .spi }
        let shortName = symbol.split(separator: ".").last.map(String.init) ?? symbol
        return shortName.hasPrefix("_") ? .underscored : .public
    }

    private func parseAvailability(_ list: [String]) -> CatalogAvailability {
        var result = CatalogAvailability()
        for raw in list {
            if raw.contains("unavailable") && (raw.contains("iOS") || raw.contains("*")) {
                result.isUnavailable = true
            }
            if raw.contains("deprecated") && (raw.contains("iOS") || raw.contains("*")) {
                if !raw.contains("deprecated: 100000") {
                    result.isDeprecated = true
                }
            }
            if let introducedMatch = extractVersion(raw, prefix: "introduced:") {
                result.introduced = OSVersion(string: introducedMatch)
            } else if raw.hasPrefix("@available(iOS ") {
                let rest = raw.dropFirst("@available(iOS ".count)
                if let end = rest.firstIndex(of: ",") ?? rest.firstIndex(of: ")") {
                    result.introduced = OSVersion(string: String(rest[..<end]))
                }
            }
            if let deprecatedMatch = extractVersion(raw, prefix: "deprecated:") {
                let v = OSVersion(string: deprecatedMatch)
                if let v, !v.isFuturePlaceholder {
                    result.deprecated = v
                    result.isDeprecated = true
                }
            }
        }
        return result
    }

    private func extractVersion(_ string: String, prefix: String) -> String? {
        guard let range = string.range(of: prefix) else { return nil }
        let after = string[range.upperBound...].trimmingCharacters(in: .whitespaces)
        let token = after.split(whereSeparator: { $0 == "," || $0 == ")" || $0.isWhitespace }).first
        return token.map(String.init)
    }
}
