import SwiftUI
import CatalogModel

struct SymbolListView: View {
    let section: NavigationSection
    @Binding var selectedSymbol: CatalogSymbol?
    @ObservedObject var store = CatalogStore.shared
    @State private var searchText = ""

    var body: some View {
        let displayedSymbols = symbolsToDisplay()

        List(selection: $selectedSymbol) {
            if displayedSymbols.isEmpty {
                ContentUnavailableView(
                    "list.no_symbols",
                    systemImage: "magnifyingglass",
                    description: Text("list.no_symbols_description")
                )
            } else {
                ForEach(displayedSymbols) { symbol in
                    NavigationLink(value: symbol) {
                        SymbolRow(symbol: symbol)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(titleForSection())
        .searchable(text: $searchText, prompt: "search.placeholder")
    }

    private func symbolsToDisplay() -> [CatalogSymbol] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return store.symbols(for: section)
        } else {
            let results = store.search(searchText)
            return results.compactMap { store.symbol(for: $0.symbolID) }
        }
    }

    private func titleForSection() -> LocalizedStringKey {
        switch section {
        case .home: return "sidebar.home"
        case .components: return "sidebar.components"
        case .swiftUI: return "sidebar.swiftui"
        case .uiKit: return "sidebar.uikit"
        case .modifiers: return "sidebar.modifiers"
        case .family(let id):
            if let fam = store.family(for: id) {
                return LocalizedStringKey(fam.titleKey)
            }
            return "sidebar.families"
        case .favorites: return "sidebar.favorites"
        case .recents: return "sidebar.recents"
        case .allSymbols: return "sidebar.all_symbols"
        case .settings: return "sidebar.settings"
        }
    }
}

struct SymbolRow: View {
    let symbol: CatalogSymbol

    var body: some View {
        HStack(spacing: 12) {
            // Kind icon
            Image(systemName: iconForSymbol(symbol))
                .font(.body)
                .foregroundStyle(symbol.framework == .swiftUI ? Color.blue : Color.orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(symbol.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    if symbol.hasLiveDemo {
                        Image(systemName: "play.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }

                HStack(spacing: 6) {
                    // Framework badge
                    Text(symbol.framework.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(symbol.framework == .swiftUI ? Color.blue.opacity(0.12) : Color.orange.opacity(0.12), in: Capsule())
                        .foregroundStyle(symbol.framework == .swiftUI ? Color.blue : Color.orange)

                    // Kind label
                    Text(symbol.kind.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if let intro = symbol.availability.introduced {
                        Text("iOS \(intro.description)+")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func iconForSymbol(_ sym: CatalogSymbol) -> String {
        switch sym.kind {
        case .view: return "rectangle.fill.on.rectangle.fill"
        case .modifier: return "slider.horizontal.below.rectangle"
        case .classType: return "c.square"
        case .structure: return "s.square"
        case .enumeration: return "e.square"
        case .protocolType: return "p.square"
        default: return "cube"
        }
    }
}
