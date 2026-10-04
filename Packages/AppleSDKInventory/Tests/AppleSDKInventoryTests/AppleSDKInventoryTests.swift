import Foundation
import Testing
import CatalogModel
@testable import AppleSDKInventoryCore

@Suite("AppleSDKInventory unit tests")
struct AppleSDKInventoryTests {
    private func fixture(_ name: String) -> URL {
        Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures")!
    }

    private func fixturesDir() -> URL {
        fixture("UIKit.symbols.json").deletingLastPathComponent()
    }

    @Test("SwiftUI parser captures views, modifiers, option sets, and parameters")
    func swiftUIParser() throws {
        let (fileId, declarations) = try SwiftUIInterfaceParser.parse(
            .init(module: "SwiftUICore", url: fixture("SwiftUICore.swiftinterface"))
        )
        #expect(fileId.module == "SwiftUICore")
        #expect(fileId.sha256.count == 64)

        let bySymbol = Dictionary(grouping: declarations, by: \.symbol)
        #expect(bySymbol["NavigationStack"]?.first?.kind == .view)
        #expect(bySymbol["NavigationView"]?.first?.kind == .view)
        #expect(bySymbol["TextEditor"]?.first?.kind == .view)
        #expect(bySymbol["Axis.Set"]?.first?.optionSetCases == ["horizontal", "vertical"])

        // Modifier
        let navTitle = bySymbol["navigationBarTitleDisplayMode"]?.first
        #expect(navTitle?.kind == .modifier)
        #expect(navTitle?.signatures.first?.parameters.first?.name == "displayMode")

        // Searchable
        let searchable = bySymbol["searchable"]?.first
        #expect(searchable?.signatures.first?.parameters.first?.isBinding == true)
    }

    @Test("UIKit symbol graph extractor extracts classes, members, and superclasses")
    func uikitExtractor() throws {
        let declarations = try UIKitSymbolGraphExtractor.extract(from: fixturesDir())
        let byName = Dictionary(grouping: declarations, by: \.symbol)

        let button = byName["UIButton"]?.first
        #expect(button != nil)
        #expect(button?.kind == .classType)
        #expect(button?.superclass == "UIControl")
        #expect(button?.availability.introduced?.description == "2.0")
        #expect(button?.signatures.count == 1) // init()
        #expect(button?.members.contains(where: { $0.name == "configuration" }) == true)

        let control = byName["UIControl"]?.first
        #expect(control?.superclass == "UIView")
    }

    @Test("CatalogBuilder validates sentinels and builds manifest")
    func catalogBuilder() throws {
        let (_, swiftUICore) = try SwiftUIInterfaceParser.parse(
            .init(module: "SwiftUICore", url: fixture("SwiftUICore.swiftinterface"))
        )
        let (_, swiftUI) = try SwiftUIInterfaceParser.parse(
            .init(module: "SwiftUI", url: fixture("SwiftUI.swiftinterface"))
        )
        var allSwiftUI = swiftUICore + swiftUI

        // Add additional synthetic sentinels to meet swiftUISentinels list for test
        for sentinel in CatalogBuilder.swiftUISentinels {
            if !allSwiftUI.contains(where: { $0.symbol == sentinel }) {
                allSwiftUI.append(.init(
                    id: "SwiftUI.\(sentinel)",
                    framework: .swiftUI,
                    module: "SwiftUI",
                    symbol: sentinel,
                    qualifiedName: sentinel,
                    kind: .view
                ))
            }
        }

        let uiKitDeclarations = try UIKitSymbolGraphExtractor.extract(from: fixturesDir())

        let families = [
            CatalogFamily(id: "menus-actions", titleKey: "family.menus_actions", systemImage: "hand.tap", group: .hig, order: 1),
            CatalogFamily(id: "presentation", titleKey: "family.presentation", systemImage: "macwindow", group: .hig, order: 2),
            CatalogFamily(id: "developer-reference", titleKey: "family.developer_reference", systemImage: "book", group: .developer, order: 3),
        ]

        let result = try CatalogBuilder.build(inputs: .init(
            swiftUIDeclarations: allSwiftUI,
            uiKitDeclarations: uiKitDeclarations,
            families: families,
            aliases: ["pushbutton": ["UIKit.UIButton", "SwiftUI.Button"]],
            relationships: [["swiftUI": "SwiftUI.Button", "uiKit": "UIKit.UIButton"]],
            docOverrides: [:],
            demos: [
                .init(id: "button", symbol: "SwiftUI.Button", family: "menus-actions", priority: 100),
                .init(id: "uibutton", symbol: "UIKit.UIButton", family: "menus-actions", priority: 100)
            ],
            sdkIdentity: .init(
                xcodeVersion: "Xcode 27.0",
                xcodeBuild: "27A266a",
                sdkName: "iphoneos",
                sdkVersion: "27.0",
                targetTriple: "arm64e-apple-ios",
                sdkPath: "/path"
            )
        ))

        #expect(result.manifest.families.count == 3)
        #expect(result.swiftUIFile.symbols.contains(where: { $0.name == "Button" && $0.hasLiveDemo }))
        #expect(result.uiKitFile.symbols.contains(where: { $0.name == "UIButton" && $0.hasLiveDemo }))

        let buttonSymbol = result.uiKitFile.symbols.first(where: { $0.name == "UIButton" })
        #expect(buttonSymbol?.related.first?.target == "SwiftUI.Button")
    }

    @Test("Sentinel validation fails when a sentinel is missing")
    func sentinelFailure() {
        #expect(throws: Error.self) {
            try CatalogBuilder.build(inputs: .init(
                swiftUIDeclarations: [], // Missing all sentinels
                uiKitDeclarations: [],
                families: [],
                aliases: [:],
                relationships: [],
                docOverrides: [:],
                demos: [],
                sdkIdentity: .init(xcodeVersion: "Xcode", xcodeBuild: "1", sdkName: "iphoneos", sdkVersion: "27.0", targetTriple: "arm64", sdkPath: "")
            ))
        }
    }
}
