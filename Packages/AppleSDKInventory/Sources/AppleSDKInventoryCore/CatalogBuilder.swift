import Foundation
import CatalogModel

public struct CatalogBuilderInputs: Sendable {
    public var swiftUIDeclarations: [SDKDeclaration]
    public var uiKitDeclarations: [SDKDeclaration]
    public var families: [CatalogFamily]
    public var aliases: [String: [String]]
    public var relationships: [[String: String]]
    public var docOverrides: [String: String]
    public var demos: [DemoMetadata]
    public var sdkIdentity: SDKIdentity

    public init(
        swiftUIDeclarations: [SDKDeclaration],
        uiKitDeclarations: [SDKDeclaration],
        families: [CatalogFamily],
        aliases: [String: [String]],
        relationships: [[String: String]],
        docOverrides: [String: String],
        demos: [DemoMetadata],
        sdkIdentity: SDKIdentity
    ) {
        self.swiftUIDeclarations = swiftUIDeclarations
        self.uiKitDeclarations = uiKitDeclarations
        self.families = families
        self.aliases = aliases
        self.relationships = relationships
        self.docOverrides = docOverrides
        self.demos = demos
        self.sdkIdentity = sdkIdentity
    }
}

public struct CatalogBuildResult: Sendable {
    public var manifest: CatalogManifest
    public var swiftUIFile: CatalogFrameworkFile
    public var uiKitFile: CatalogFrameworkFile
}

public enum CatalogBuilder {
    // Required sentinels
    public static let swiftUISentinels: Set<String> = [
        "Button", "Toggle", "NavigationStack", "NavigationSplitView", "Menu",
        "TextField", "sheet", "popover", "presentationDetents", "searchable"
    ]

    public static let uiKitSentinels: Set<String> = [
        "UIView", "UIViewController", "UIControl", "UIButton", "UILabel", "UIImageView",
        "UITextField", "UITextView", "UISwitch", "UISlider", "UIStepper", "UIDatePicker",
        "UIPickerView", "UISearchBar", "UISearchController", "UINavigationController",
        "UITabBarController", "UISplitViewController", "UITableView", "UICollectionView",
        "UIAlertController", "UIPopoverPresentationController", "UISheetPresentationController",
        "UIMenu", "UIAction", "UIContextMenuInteraction", "UIActivityViewController",
        "UIDocumentPickerViewController", "UIColorPickerViewController", "UIFontPickerViewController"
    ]

    public static func build(inputs: CatalogBuilderInputs) throws -> CatalogBuildResult {
        // 1. Merge SwiftUI overloads
        let mergedSwiftUI = mergeSwiftUIDeclarations(inputs.swiftUIDeclarations)
        let mergedUIKit = inputs.uiKitDeclarations

        // 2. Validate sentinels
        try validateSentinels(swiftUI: mergedSwiftUI, uiKit: mergedUIKit)

        // 3. Build lookup maps for demos, families, aliases, relationships
        let demoBySymbol = Dictionary(uniqueKeysWithValues: inputs.demos.map { ($0.symbol, $0) })
        let familyByID = Dictionary(uniqueKeysWithValues: inputs.families.map { ($0.id, $0) })

        var aliasesBySymbol: [String: [String]] = [:]
        for (alias, symbolIDs) in inputs.aliases {
            for symID in symbolIDs {
                aliasesBySymbol[symID, default: []].append(alias)
            }
        }

        var relationsBySymbol: [String: [CatalogRelation]] = [:]
        for rel in inputs.relationships {
            if let sw = rel["swiftUI"], let ui = rel["uiKit"] {
                let note = rel["noteKey"]
                relationsBySymbol[sw, default: []].append(.init(kind: .relatedUIKit, target: ui, noteKey: note))
                relationsBySymbol[ui, default: []].append(.init(kind: .relatedSwiftUI, target: sw, noteKey: note))
            }
        }

        // 4. Validate that all demos map to real SDK symbols
        let allIDs = Set(mergedSwiftUI.map(\.id) + mergedUIKit.map(\.id))
        for demo in inputs.demos {
            guard allIDs.contains(demo.symbol) else {
                throw NSError(
                    domain: "AppleSDKInventory",
                    code: 10,
                    userInfo: [NSLocalizedDescriptionKey: "Demo \(demo.id) references nonexistent SDK symbol \(demo.symbol)"]
                )
            }
        }

        // 5. Convert to CatalogSymbol
        let swiftUISymbols = mergedSwiftUI.map { decl in
            makeCatalogSymbol(
                decl: decl,
                demo: demoBySymbol[decl.id],
                aliases: aliasesBySymbol[decl.id] ?? [],
                relations: relationsBySymbol[decl.id] ?? [],
                docOverrides: inputs.docOverrides,
                familyLookup: familyByID
            )
        }

        let uiKitSymbols = mergedUIKit.map { decl in
            makeCatalogSymbol(
                decl: decl,
                demo: demoBySymbol[decl.id],
                aliases: aliasesBySymbol[decl.id] ?? [],
                relations: relationsBySymbol[decl.id] ?? [],
                docOverrides: inputs.docOverrides,
                familyLookup: familyByID
            )
        }

        // 6. Counts
        let swiftUICounts = makeFrameworkCounts(swiftUISymbols)
        let uiKitCounts = makeFrameworkCounts(uiKitSymbols)

        let manifest = CatalogManifest(
            schemaVersion: CatalogManifest.currentSchemaVersion,
            generatorVersion: "1.0.0",
            sdk: inputs.sdkIdentity,
            frameworks: [
                .init(framework: .swiftUI, file: CatalogManifest.frameworkFileName(.swiftUI), counts: swiftUICounts),
                .init(framework: .uiKit, file: CatalogManifest.frameworkFileName(.uiKit), counts: uiKitCounts),
            ],
            families: inputs.families,
            demos: inputs.demos
        )

        return CatalogBuildResult(
            manifest: manifest,
            swiftUIFile: .init(framework: .swiftUI, symbols: swiftUISymbols),
            uiKitFile: .init(framework: .uiKit, symbols: uiKitSymbols)
        )
    }

    private static func validateSentinels(swiftUI: [SDKDeclaration], uiKit: [SDKDeclaration]) throws {
        let discoveredSwiftUI = Set(swiftUI.map(\.symbol))
        let missingSwiftUI = swiftUISentinels.subtracting(discoveredSwiftUI)
        guard missingSwiftUI.isEmpty else {
            throw NSError(
                domain: "AppleSDKInventory",
                code: 11,
                userInfo: [NSLocalizedDescriptionKey: "SwiftUI extraction missing required sentinels: \(missingSwiftUI.sorted().joined(separator: ", "))"]
            )
        }

        let discoveredUIKit = Set(uiKit.map(\.symbol))
        let missingUIKit = uiKitSentinels.subtracting(discoveredUIKit)
        guard missingUIKit.isEmpty else {
            throw NSError(
                domain: "AppleSDKInventory",
                code: 12,
                userInfo: [NSLocalizedDescriptionKey: "UIKit extraction missing required sentinels: \(missingUIKit.sorted().joined(separator: ", "))"]
            )
        }
    }

    private static func mergeSwiftUIDeclarations(_ declarations: [SDKDeclaration]) -> [SDKDeclaration] {
        var merged: [String: SDKDeclaration] = [:]
        for original in declarations {
            let key = "\(original.framework.rawValue)|\(original.kind.rawValue)|\(original.symbol)"
            if var existing = merged[key] {
                for sig in original.signatures where !existing.signatures.contains(sig) {
                    existing.signatures.append(sig)
                }
                for mem in original.members where !existing.members.contains(mem) {
                    existing.members.append(mem)
                }
                existing.enumCases = Array(Set(existing.enumCases + original.enumCases)).sorted()
                existing.optionSetCases = Array(Set(existing.optionSetCases + original.optionSetCases)).sorted()
                merged[key] = existing
            } else {
                merged[key] = original
            }
        }
        return merged.values.sorted { ($0.qualifiedName, $0.kind.rawValue) < ($1.qualifiedName, $1.kind.rawValue) }
    }

    private static func makeCatalogSymbol(
        decl: SDKDeclaration,
        demo: DemoMetadata?,
        aliases: [String],
        relations: [CatalogRelation],
        docOverrides: [String: String],
        familyLookup: [String: CatalogFamily]
    ) -> CatalogSymbol {
        let (category, family, tags) = classify(decl: decl, demo: demo)
        let docPath = docOverrides[decl.id] ?? defaultDocumentationPath(for: decl)
        let higPath = familyLookup[family ?? ""]?.higPath

        let signatures = decl.signatures.map { sig in
            CatalogSignature(
                declaration: sig.declaration,
                parameters: sig.parameters.map { CatalogParameter(label: $0.label, name: $0.name, type: $0.type, defaultValue: $0.defaultValue) },
                returnType: sig.returnType,
                availability: sig.availability,
                isAsync: sig.isAsync,
                isThrowing: sig.isThrowing
            )
        }

        let members = decl.members.map { mem in
            CatalogMember(
                name: mem.name,
                kind: mem.kind,
                declaration: mem.declaration,
                availability: mem.availability,
                isRequirement: mem.isRequirement,
                objcName: mem.objcName
            )
        }

        return CatalogSymbol(
            id: decl.id,
            framework: decl.framework,
            modules: [decl.module],
            name: decl.symbol,
            qualifiedName: decl.qualifiedName,
            kind: decl.kind,
            category: category,
            family: family,
            tags: tags,
            aliases: aliases,
            availability: decl.availability,
            visibility: decl.visibility,
            origin: decl.origin,
            objcName: decl.preciseIdentifier?.hasPrefix("c:objc") == true ? decl.symbol : nil,
            genericParameters: decl.genericParameters,
            superclass: decl.superclass,
            conformances: decl.conformances,
            signatures: signatures,
            members: members,
            enumCases: decl.enumCases,
            optionSetCases: decl.optionSetCases,
            documentationPath: docPath,
            higPath: higPath,
            related: relations,
            demoID: demo?.id,
            priority: demo?.priority ?? (category.isVisual ? 50 : 0)
        )
    }

    private static func classify(decl: SDKDeclaration, demo: DemoMetadata?) -> (CatalogCategory, String?, [String]) {
        if let demo {
            return (.visualComponent, demo.family, ["control", "curated"])
        }
        if decl.visibility != .public {
            return (.internal, "developer-reference", ["internal"])
        }
        if decl.availability.isUnavailable {
            return (.unavailable, "developer-reference", ["unavailable"])
        }
        if decl.availability.isDeprecated {
            return (.deprecated, "developer-reference", ["deprecated"])
        }

        // Framework specific heuristics
        if decl.framework == .swiftUI {
            if decl.kind == .view {
                return (.visualComponent, inferFamily(name: decl.symbol), ["view"])
            } else if decl.kind == .modifier {
                return (.visualModifier, inferModifierFamily(name: decl.symbol), ["modifier"])
            } else if decl.kind == .protocolType {
                return (.referenceOnly, "developer-reference", ["protocol"])
            } else {
                return (.nonvisual, "developer-reference", ["type"])
            }
        } else {
            // UIKit
            if decl.superclass == "UIView" || decl.conformances.contains("UIView") || decl.symbol.hasSuffix("View") || decl.symbol.hasSuffix("Control") {
                return (.visualComponent, inferFamily(name: decl.symbol), ["uiview"])
            } else if decl.superclass == "UIViewController" || decl.symbol.hasSuffix("ViewController") {
                return (.presentation, "presentation", ["viewcontroller"])
            } else if decl.kind == .protocolType {
                return (.referenceOnly, "developer-reference", ["protocol"])
            } else {
                return (.nonvisual, "developer-reference", ["type"])
            }
        }
    }

    private static func inferFamily(name: String) -> String {
        let n = name.lowercased()
        if n.contains("button") || n.contains("menu") || n.contains("action") { return "menus-actions" }
        if n.contains("text") || n.contains("slider") || n.contains("stepper") || n.contains("picker") || n.contains("switch") || n.contains("toggle") { return "selection-input" }
        if n.contains("nav") || n.contains("search") || n.contains("tab") { return "navigation-search" }
        if n.contains("sheet") || n.contains("popover") || n.contains("alert") || n.contains("dialog") { return "presentation" }
        if n.contains("progress") || n.contains("gauge") || n.contains("activity") || n.contains("status") { return "status" }
        if n.contains("grid") || n.contains("list") || n.contains("stack") || n.contains("table") || n.contains("collection") || n.contains("split") { return "layout-organization" }
        if n.contains("label") || n.contains("image") || n.contains("content") { return "content" }
        return "content"
    }

    private static func inferModifierFamily(name: String) -> String {
        let n = name.lowercased()
        if n.contains("sheet") || n.contains("popover") || n.contains("alert") || n.contains("confirmation") || n.contains("cover") || n.contains("inspector") { return "presentation" }
        if n.contains("navigation") || n.contains("search") || n.contains("tab") || n.contains("toolbar") { return "navigation-search" }
        if n.contains("accessibility") { return "accessibility" }
        if n.contains("gesture") || n.contains("on") || n.contains("hover") { return "gestures-interaction" }
        if n.contains("background") || n.contains("foreground") || n.contains("tint") || n.contains("color") || n.contains("material") || n.contains("blur") || n.contains("shadow") { return "effects-materials" }
        return "effects-materials"
    }

    private static func defaultDocumentationPath(for decl: SDKDeclaration) -> String {
        let fw = decl.framework.rawValue.lowercased()
        if decl.kind == .modifier {
            return "\(fw)/view/\(decl.symbol.lowercased())"
        }
        let parts = decl.qualifiedName.split(separator: ".").map { $0.lowercased() }
        return ([fw] + parts).joined(separator: "/")
    }

    private static func makeFrameworkCounts(_ symbols: [CatalogSymbol]) -> [String: Int] {
        var counts: [String: Int] = [:]
        counts["symbols.total"] = symbols.count
        counts["symbols.public"] = symbols.count { $0.visibility == .public }
        counts["symbols.visual"] = symbols.count { $0.category.isVisual }
        counts["symbols.demos"] = symbols.count { $0.hasLiveDemo }
        for kind in SymbolKind.allCases {
            counts["kind.\(kind.rawValue)"] = symbols.count { $0.kind == kind }
        }
        for cat in CatalogCategory.allCases {
            counts["category.\(cat.rawValue)"] = symbols.count { $0.category == cat }
        }
        return counts
    }
}
