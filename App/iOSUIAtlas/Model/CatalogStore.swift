import Foundation
import SwiftUI
import CatalogModel
import CatalogDemos

public enum NavigationSection: Hashable, Sendable {
    case home
    case components
    case swiftUI
    case uiKit
    case modifiers
    case family(String)
    case favorites
    case recents
    case allSymbols
    case settings
}

@MainActor
public final class CatalogStore: ObservableObject {
    public static let shared = CatalogStore()

    @Published public var isLoading = true
    @Published public var manifest: CatalogManifest?
    @Published public var allSymbols: [CatalogSymbol] = []
    @Published public var showInternalSymbols = false

    private var symbolsByID: [String: CatalogSymbol] = [:]
    private var searchIndex: SearchIndex?

    public init() {
        // Will load from bundle on start
    }

    public func loadCatalog(bundle: Bundle = .main) async {
        isLoading = true
        defer { isLoading = false }

        // Find catalog files
        guard let manifestURL = bundle.url(forResource: "catalog-manifest", withExtension: "json")
                ?? bundle.url(forResource: "catalog-manifest", withExtension: "json", subdirectory: "Catalog") else {
            // Load fallback sample dataset if bundle files not yet generated
            loadFallbackData()
            return
        }

        do {
            let decoder = JSONDecoder()
            let manifestData = try Data(contentsOf: manifestURL)
            let loadedManifest = try decoder.decode(CatalogManifest.self, from: manifestData)

            var loadedSymbols: [CatalogSymbol] = []

            for fwSummary in loadedManifest.frameworks {
                let baseName = (fwSummary.file as NSString).deletingPathExtension
                if let fwURL = bundle.url(forResource: baseName, withExtension: "json")
                    ?? bundle.url(forResource: baseName, withExtension: "json", subdirectory: "Catalog") {
                    let fwData = try Data(contentsOf: fwURL)
                    let fwFile = try decoder.decode(CatalogFrameworkFile.self, from: fwData)
                    loadedSymbols.append(contentsOf: fwFile.symbols)
                }
            }

            self.manifest = loadedManifest
            self.setSymbols(loadedSymbols)
        } catch {
            print("Failed to load catalog bundle: \(error)")
            loadFallbackData()
        }
    }

    public func setSymbols(_ symbols: [CatalogSymbol]) {
        self.allSymbols = symbols
        self.symbolsByID = Dictionary(uniqueKeysWithValues: symbols.map { ($0.id, $0) })
        self.searchIndex = SearchIndex(symbols: symbols)
    }

    public func symbol(for id: String) -> CatalogSymbol? {
        symbolsByID[id]
    }

    public func symbols(for section: NavigationSection) -> [CatalogSymbol] {
        let baseList = allSymbols.filter { sym in
            showInternalSymbols || !sym.isInternal
        }

        switch section {
        case .home, .components:
            return baseList.filter { $0.category.isVisual }
        case .swiftUI:
            return baseList.filter { $0.framework == .swiftUI }
        case .uiKit:
            return baseList.filter { $0.framework == .uiKit }
        case .modifiers:
            return baseList.filter { $0.kind == .modifier }
        case .family(let familyID):
            return baseList.filter { $0.family == familyID }
        case .favorites:
            let favs = FavoritesManager.shared.favoriteIDs
            return baseList.filter { favs.contains($0.id) }
        case .recents:
            let recents = FavoritesManager.shared.recentIDs
            return recents.compactMap { symbolsByID[$0] }.filter { showInternalSymbols || !$0.isInternal }
        case .allSymbols:
            return baseList
        case .settings:
            return []
        }
    }

    public func search(_ query: String) -> [SearchResult] {
        guard let searchIndex else { return [] }
        return searchIndex.search(query, options: .init(includeInternal: showInternalSymbols, limit: 150))
    }

    public var families: [CatalogFamily] {
        manifest?.families ?? []
    }

    public func family(for id: String) -> CatalogFamily? {
        families.first { $0.id == id }
    }

    // Fallback dataset initialized from CatalogDemos registry when bundle JSON is pending
    public func loadFallbackData() {
        let demos = CatalogDemoRegistry.shared.allDemos
        var fallbackSymbols: [CatalogSymbol] = []

        let fallbackRelationships: [String: [CatalogRelation]] = [
            "SwiftUI.Button": [.init(kind: .counterpart, target: "UIKit.UIButton", note: "UIKit equivalent")],
            "UIKit.UIButton": [.init(kind: .counterpart, target: "SwiftUI.Button", note: "SwiftUI equivalent")],
            "SwiftUI.Toggle": [.init(kind: .counterpart, target: "UIKit.UISwitch", note: "UIKit equivalent")],
            "UIKit.UISwitch": [.init(kind: .counterpart, target: "SwiftUI.Toggle", note: "SwiftUI equivalent")],
            "SwiftUI.Slider": [.init(kind: .counterpart, target: "UIKit.UISlider", note: "UIKit equivalent")],
            "UIKit.UISlider": [.init(kind: .counterpart, target: "SwiftUI.Slider", note: "SwiftUI equivalent")],
            "SwiftUI.TextField": [.init(kind: .counterpart, target: "UIKit.UITextField", note: "UIKit equivalent")],
            "UIKit.UITextField": [.init(kind: .counterpart, target: "SwiftUI.TextField", note: "SwiftUI equivalent")],
            "SwiftUI.TextEditor": [.init(kind: .counterpart, target: "UIKit.UITextView", note: "UIKit equivalent")],
            "UIKit.UITextView": [.init(kind: .counterpart, target: "SwiftUI.TextEditor", note: "SwiftUI equivalent")],
            "SwiftUI.DatePicker": [.init(kind: .counterpart, target: "UIKit.UIDatePicker", note: "UIKit equivalent")],
            "UIKit.UIDatePicker": [.init(kind: .counterpart, target: "SwiftUI.DatePicker", note: "SwiftUI equivalent")],
            "SwiftUI.ProgressView": [.init(kind: .counterpart, target: "UIKit.UIProgressView", note: "UIKit equivalent")],
            "UIKit.UIProgressView": [.init(kind: .counterpart, target: "SwiftUI.ProgressView", note: "SwiftUI equivalent")]
        ]

        for demo in demos {
            let isSwiftUI = demo.symbolID.hasPrefix("SwiftUI")
            let name = demo.symbolID.split(separator: ".").last.map(String.init) ?? demo.symbolID
            fallbackSymbols.append(.init(
                id: demo.symbolID,
                framework: isSwiftUI ? .swiftUI : .uiKit,
                modules: [isSwiftUI ? "SwiftUI" : "UIKit"],
                name: name,
                qualifiedName: name,
                kind: demo.symbolID.contains(".View.") ? .modifier : (isSwiftUI ? .view : .classType),
                category: .visualComponent,
                family: demo.familyID,
                demoID: demo.symbolID,
                related: fallbackRelationships[demo.symbolID] ?? [],
                priority: 100
            ))
        }

        let families = [
            CatalogFamily(id: "content", titleKey: "family.content", systemImage: "text.quote", group: .hig, order: 1),
            CatalogFamily(id: "layout-organization", titleKey: "family.layout_organization", systemImage: "rectangle.split.2x2", group: .hig, order: 2),
            CatalogFamily(id: "menus-actions", titleKey: "family.menus_actions", systemImage: "hand.tap", group: .hig, order: 3),
            CatalogFamily(id: "navigation-search", titleKey: "family.navigation_search", systemImage: "magnifyingglass", group: .hig, order: 4),
            CatalogFamily(id: "presentation", titleKey: "family.presentation", systemImage: "rectangle.stack.badge.plus", group: .hig, order: 5),
            CatalogFamily(id: "selection-input", titleKey: "family.selection_input", systemImage: "slider.horizontal.3", group: .hig, order: 6),
            CatalogFamily(id: "status", titleKey: "family.status", systemImage: "gauge.with.needle", group: .hig, order: 7),
            CatalogFamily(id: "system-experiences", titleKey: "family.system_experiences", systemImage: "apple.terminal", group: .hig, order: 8),
            CatalogFamily(id: "developer-reference", titleKey: "family.developer_reference", systemImage: "book.closed", group: .developer, order: 9)
        ]

        self.manifest = CatalogManifest(
            schemaVersion: 1,
            generatorVersion: "1.0.0",
            sdk: .init(xcodeVersion: "Xcode 27.0", xcodeBuild: "27A266a", sdkName: "iphoneos", sdkVersion: "27.0", targetTriple: "arm64e-apple-ios", sdkPath: ""),
            frameworks: [
                .init(framework: .swiftUI, file: "catalog-swiftui.json", counts: ["symbols.total": fallbackSymbols.count(where: { $0.framework == .swiftUI })]),
                .init(framework: .uiKit, file: "catalog-uikit.json", counts: ["symbols.total": fallbackSymbols.count(where: { $0.framework == .uiKit })])
            ],
            families: families,
            demos: CatalogDemoRegistry.shared.demoMetadataList
        )
        self.setSymbols(fallbackSymbols)
    }
}
