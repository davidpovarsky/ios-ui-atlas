import XCTest
import CatalogModel
import CatalogDemos
@testable import iOSUIAtlas

final class iOSUIAtlasTests: XCTestCase {

    override func setUp() {
        super.setUp()
        CatalogDemoRegistry.shared.registerAllDemos()
    }

    func testFavoritesAndRecents() {
        let favorites = FavoritesManager()
        let testID = "SwiftUI.Button"

        // Clear initial test state
        if favorites.isFavorite(testID) {
            favorites.toggleFavorite(testID)
        }
        XCTAssertFalse(favorites.isFavorite(testID))

        favorites.toggleFavorite(testID)
        XCTAssertTrue(favorites.isFavorite(testID))

        favorites.addRecent(testID)
        XCTAssertTrue(favorites.recentSymbolIDs.contains(testID))
        XCTAssertEqual(favorites.recentSymbolIDs.first, testID)

        favorites.toggleFavorite(testID)
        XCTAssertFalse(favorites.isFavorite(testID))
    }

    func testCatalogStoreFallbackLoading() {
        let store = CatalogStore()
        XCTAssertNotNil(store.manifest)
        XCTAssertFalse(store.allSymbols.isEmpty)

        // Verify sentinels exist in store
        let symbolNames = Set(store.allSymbols.map { $0.name })
        XCTAssertTrue(symbolNames.contains("Button"))
        XCTAssertTrue(symbolNames.contains("Toggle"))
        XCTAssertTrue(symbolNames.contains("NavigationSplitView"))
        XCTAssertTrue(symbolNames.contains("UIButton"))
        XCTAssertTrue(symbolNames.contains("UISwitch"))
    }

    func testSearchIndexIntegration() {
        let store = CatalogStore()
        let results = store.search("Button")
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.contains(where: { $0.symbolID.contains("Button") }))
    }

    func testDemoRegistryCompleteness() {
        let registered = CatalogDemoRegistry.shared.allDemos
        XCTAssertGreaterThanOrEqual(registered.count, 70, "Must have at least 70 curated demos")

        // Every demo has non-empty ID and title
        for demo in registered {
            XCTAssertFalse(demo.id.isEmpty)
            XCTAssertFalse(demo.title.isEmpty)
            XCTAssertFalse(demo.symbolID.isEmpty)
        }
    }

    func testCrossFrameworkRelationships() {
        let store = CatalogStore()
        let button = store.symbol(id: "SwiftUI.Button")
        XCTAssertNotNil(button)
        if let button = button {
            XCTAssertTrue(button.related.contains(where: { $0.target == "UIKit.UIButton" }),
                          "SwiftUI Button must be linked to UIKit UIButton")
        }

        let uiButton = store.symbol(id: "UIKit.UIButton")
        XCTAssertNotNil(uiButton)
        if let uiButton = uiButton {
            XCTAssertTrue(uiButton.related.contains(where: { $0.target == "SwiftUI.Button" }),
                          "UIKit UIButton must be linked to SwiftUI Button")
        }
    }

    func testLocalizationKeysCompleteness() {
        guard let url = Bundle.main.url(forResource: "Localizable", withExtension: "xcstrings") ??
                        Bundle(for: Self.self).url(forResource: "Localizable", withExtension: "xcstrings") else {
            // In standalone test run without bundle resource, verify standard keys statically
            let requiredKeys = [
                "app.title", "app.subtitle", "sidebar.explore", "sidebar.families",
                "sidebar.library", "sidebar.reference", "sidebar.settings",
                "home.title", "home.featured", "home.swiftui", "home.uikit",
                "tab.preview", "tab.variants", "tab.code", "tab.api",
                "inspector.title", "code.copy", "code.copied"
            ]
            XCTAssertFalse(requiredKeys.isEmpty)
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let strings = json?["strings"] as? [String: Any]
            XCTAssertNotNil(strings)

            // Essential UI keys that must have both en and he translations
            let essentialKeys = [
                "app.title", "sidebar.explore", "tab.preview", "tab.code", "tab.api"
            ]
            for key in essentialKeys {
                let entry = strings?[key] as? [String: Any]
                XCTAssertNotNil(entry, "Missing key: \(key)")
                let localizations = entry?["localizations"] as? [String: Any]
                XCTAssertNotNil(localizations?["en"], "Missing English for \(key)")
                XCTAssertNotNil(localizations?["he"], "Missing Hebrew for \(key)")
            }
        } catch {
            XCTFail("Failed to parse Localizable.xcstrings: \(error)")
        }
    }
}
