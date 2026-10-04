import Foundation
import Testing
import CatalogModel
@testable import CatalogDemos

@Suite("CatalogDemos Tests")
struct CatalogDemosTests {
    @Test("All 71 curated demos are registered and valid")
    @MainActor
    func registryCompleteness() {
        let registry = CatalogDemoRegistry.shared
        let all = registry.allDemos
        #expect(all.count >= 70)

        for demo in all {
            #expect(!demo.symbolID.isEmpty)
            #expect(!demo.titleKey.isEmpty)
            #expect(!demo.familyID.isEmpty)

            let state = DemoState()
            state.reset(from: demo.parameters)

            let swiftCode = demo.swiftUICode(state: state)
            #expect(!swiftCode.isEmpty)

            if !demo.variants.isEmpty {
                let v = demo.variants[0]
                state.apply(variant: v)
                #expect(!demo.swiftUICode(state: state).isEmpty)
            }
        }
    }

    @Test("SwiftUI Button and UIKit UIButton demo generation")
    @MainActor
    func buttonDemo() {
        let registry = CatalogDemoRegistry.shared
        let btn = registry.provider(for: "SwiftUI.Button")
        #expect(btn != nil)
        let state = DemoState()
        state.reset(from: btn!.parameters)
        let code = btn!.swiftUICode(state: state)
        #expect(code.contains("Button"))

        let uiBtn = registry.provider(for: "UIKit.UIButton")
        #expect(uiBtn != nil)
        let uiCode = uiBtn!.uiKitCode(state: state)
        #expect(uiCode?.contains("UIButton") == true)
    }
}
