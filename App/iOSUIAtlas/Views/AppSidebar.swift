import SwiftUI
import CatalogModel

struct AppSidebar: View {
    @Binding var selection: NavigationSection?
    @ObservedObject var store = CatalogStore.shared
    @ObservedObject var favorites = FavoritesManager.shared

    var body: some View {
        List(selection: $selection) {
            Section(header: Text("sidebar.explore")) {
                NavigationLink(value: NavigationSection.home) {
                    Label("sidebar.home", systemImage: "house")
                }
                NavigationLink(value: NavigationSection.components) {
                    Label("sidebar.components", systemImage: "square.grid.2x2")
                }
                NavigationLink(value: NavigationSection.swiftUI) {
                    Label("sidebar.swiftui", systemImage: "swift")
                }
                NavigationLink(value: NavigationSection.uiKit) {
                    Label("sidebar.uikit", systemImage: "uiwindow.split.2x1")
                }
                NavigationLink(value: NavigationSection.modifiers) {
                    Label("sidebar.modifiers", systemImage: "slider.horizontal.below.rectangle")
                }
            }

            Section(header: Text("sidebar.families")) {
                ForEach(store.families) { fam in
                    NavigationLink(value: NavigationSection.family(fam.id)) {
                        Label(LocalizedStringKey(fam.titleKey), systemImage: fam.systemImage)
                    }
                }
            }

            Section(header: Text("sidebar.library")) {
                NavigationLink(value: NavigationSection.favorites) {
                    HStack {
                        Label("sidebar.favorites", systemImage: "star")
                        Spacer()
                        if !favorites.favoriteIDs.isEmpty {
                            Text("\(favorites.favoriteIDs.count)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                NavigationLink(value: NavigationSection.recents) {
                    Label("sidebar.recents", systemImage: "clock")
                }
            }

            Section(header: Text("sidebar.reference")) {
                NavigationLink(value: NavigationSection.allSymbols) {
                    Label("sidebar.all_symbols", systemImage: "character.book.closed")
                }
            }

            Section {
                NavigationLink(value: NavigationSection.settings) {
                    Label("sidebar.settings", systemImage: "gear")
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("app.title")
    }
}
