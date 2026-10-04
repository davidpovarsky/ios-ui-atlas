import SwiftUI
import CatalogModel

struct HomeView: View {
    @ObservedObject var store = CatalogStore.shared
    @ObservedObject var favorites = FavoritesManager.shared
    @Binding var navigationSection: NavigationSection?
    @Binding var selectedSymbol: CatalogSymbol?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Framework Overview
                VStack(alignment: .leading, spacing: 12) {
                    Text("home.frameworks")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        frameworkCard(
                            title: "SwiftUI",
                            detail: swiftUIDetailText(),
                            icon: "swift",
                            color: .blue,
                            section: .swiftUI
                        )
                        frameworkCard(
                            title: "UIKit",
                            detail: uiKitDetailText(),
                            icon: "uiwindow.split.2x1",
                            color: .orange,
                            section: .uiKit
                        )
                    }
                }

                // Families Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("home.families")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 12)], spacing: 12) {
                        ForEach(store.families) { family in
                            Button(action: {
                                navigationSection = .family(family.id)
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: family.systemImage)
                                        .font(.title3)
                                        .foregroundStyle(.tint)
                                        .frame(width: 30)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(LocalizedStringKey(family.titleKey))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        let count = store.allSymbols.count { $0.family == family.id }
                                        Text("\(count)")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Quick Access
                if !favorites.favoriteIDs.isEmpty || !favorites.recentIDs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("home.quick_access")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            if !favorites.favoriteIDs.isEmpty {
                                quickAccessCard(
                                    title: "sidebar.favorites",
                                    count: favorites.favoriteIDs.count,
                                    icon: "star.fill",
                                    color: .yellow,
                                    section: .favorites
                                )
                            }
                            if !favorites.recentIDs.isEmpty {
                                quickAccessCard(
                                    title: "sidebar.recents",
                                    count: favorites.recentIDs.count,
                                    icon: "clock.fill",
                                    color: .blue,
                                    section: .recents
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("app.title")
    }

    private func frameworkCard(title: String, detail: String, icon: String, color: Color, section: NavigationSection) -> some View {
        Button(action: {
            navigationSection = section
        }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func quickAccessCard(title: LocalizedStringKey, count: Int, icon: String, color: Color, section: NavigationSection) -> some View {
        Button(action: {
            navigationSection = section
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private func swiftUIDetailText() -> String {
        let views = store.allSymbols.count { $0.framework == .swiftUI && $0.kind == .view }
        let modifiers = store.allSymbols.count { $0.framework == .swiftUI && $0.kind == .modifier }
        if views > 0 {
            return "\(views) Views · \(modifiers) Modifiers"
        }
        return "Declarative UI"
    }

    private func uiKitDetailText() -> String {
        let total = store.allSymbols.count { $0.framework == .uiKit }
        if total > 0 {
            return "\(total) Classes & APIs"
        }
        return "Imperative UI"
    }
}
