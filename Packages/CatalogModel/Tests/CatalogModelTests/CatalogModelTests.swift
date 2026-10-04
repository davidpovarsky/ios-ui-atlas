import Foundation
import Testing
@testable import CatalogModel

@Suite("CatalogModel tests")
struct CatalogModelTests {
    @Test("OSVersion compares and parses correctly")
    func osVersion() {
        let v17 = OSVersion("17")
        let v17_4 = OSVersion("17.4")
        let v26 = OSVersion("26.0.1")
        #expect(v17 != nil && v17_4 != nil && v26 != nil)
        #expect(v17! < v17_4!)
        #expect(v17_4! < v26!)
        #expect(v17!.description == "17.0")
        #expect(v26!.description == "26.0.1")
        #expect(OSVersion("100000")?.isFuturePlaceholder == true)
        #expect(OSVersion("invalid") == nil)
    }

    @Test("Search ranks exact symbol over member and tag")
    func searchRanking() {
        let button = CatalogSymbol(
            id: "SwiftUI.Button",
            framework: .swiftUI,
            modules: ["SwiftUI"],
            name: "Button",
            qualifiedName: "Button",
            kind: .view,
            category: .visualComponent,
            family: "menus-actions",
            tags: ["control", "action"],
            aliases: ["pushbutton"],
            priority: 100
        )
        let sheet = CatalogSymbol(
            id: "SwiftUI.View.sheet",
            framework: .swiftUI,
            modules: ["SwiftUI"],
            name: "sheet",
            qualifiedName: "View.sheet",
            kind: .modifier,
            category: .presentation,
            family: "presentation",
            tags: ["modal", "detents"],
            signatures: [
                .init(declaration: "func sheet(isPresented: Binding<Bool>, content: () -> Content)")
            ]
        )
        let uiSheet = CatalogSymbol(
            id: "UIKit.UISheetPresentationController",
            framework: .uiKit,
            modules: ["UIKit"],
            name: "UISheetPresentationController",
            qualifiedName: "UISheetPresentationController",
            kind: .classType,
            category: .presentation,
            family: "presentation",
            members: [
                .init(name: "detents", kind: .property, declaration: "var detents: [UISheetPresentationController.Detent]")
            ]
        )
        let index = SearchIndex(symbols: [button, sheet, uiSheet])

        let buttonResults = index.search("Button")
        #expect(buttonResults.first?.symbolID == "SwiftUI.Button")
        #expect(buttonResults.first?.reason == .exactSymbol)

        let aliasResults = index.search("pushbutton")
        #expect(aliasResults.first?.symbolID == "SwiftUI.Button")
        #expect(aliasResults.first?.reason == .exactAlias)

        let sheetResults = index.search("sheet")
        #expect(sheetResults.contains(where: { $0.symbolID == "SwiftUI.View.sheet" }))
        #expect(sheetResults.contains(where: { $0.symbolID == "UIKit.UISheetPresentationController" }))

        let detentsResults = index.search("detents")
        #expect(detentsResults.first?.matchedMember == "detents" || detentsResults.first?.reason == .familyOrTag)
    }

    @Test("Documentation URL builder produces expected canonical paths")
    func docLinks() {
        let buttonPath = DocumentationLinks.typePath(framework: .swiftUI, components: ["Button"])
        #expect(buttonPath == "swiftui/button")

        let uiButtonPath = DocumentationLinks.typePath(framework: .uiKit, components: ["UIButton"])
        #expect(uiButtonPath == "uikit/uibutton")

        let nestedConfig = DocumentationLinks.typePath(framework: .uiKit, components: ["UIButton", "Configuration"])
        #expect(nestedConfig == "uikit/uibutton/configuration")

        let modifierPath = DocumentationLinks.modifierPath(name: "sheet", labels: ["isPresented", "onDismiss", "content"])
        #expect(modifierPath == "swiftui/view/sheet(ispresented:ondismiss:content:)")
    }
}
