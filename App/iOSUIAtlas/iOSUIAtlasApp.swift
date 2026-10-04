import SwiftUI
import CatalogModel

@main
struct iOSUIAtlasApp: App {
    @StateObject private var store = CatalogStore.shared
    @State private var navigationSection: NavigationSection? = .home
    @State private var selectedSymbol: CatalogSymbol?

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                AppSidebar(selection: $navigationSection)
            } content: {
                if let section = navigationSection {
                    if section == .home {
                        HomeView(
                            navigationSection: $navigationSection,
                            selectedSymbol: $selectedSymbol
                        )
                    } else if section == .settings {
                        SettingsView()
                    } else {
                        SymbolListView(
                            section: section,
                            selectedSymbol: $selectedSymbol
                        )
                    }
                } else {
                    HomeView(
                        navigationSection: $navigationSection,
                        selectedSymbol: $selectedSymbol
                    )
                }
            } detail: {
                if let symbol = selectedSymbol {
                    SymbolDetailView(symbol: symbol)
                } else {
                    ContentUnavailableView(
                        "detail.select_symbol",
                        systemImage: "hand.tap",
                        description: Text("detail.select_symbol_description")
                    )
                }
            }
            .task {
                await store.loadCatalog()
            }
        }
    }
}
