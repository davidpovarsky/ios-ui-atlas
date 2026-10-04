import SwiftUI
import CatalogModel
import CatalogDemos

struct SymbolDetailView: View {
    let symbol: CatalogSymbol
    @ObservedObject var favorites = FavoritesManager.shared
    @ObservedObject var store = CatalogStore.shared

    @State private var selectedTab = 0
    @StateObject private var playgroundState = DemoState()
    @State private var demoProvider: CatalogDemoProvider?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView()

            Divider()

            // Main Content Area
            if let demo = demoProvider {
                // Visual demo exists: show Preview, Variants, Code, API tabs
                tabBar()

                Group {
                    switch selectedTab {
                    case 0:
                        previewTab(demo: demo)
                    case 1:
                        variantsTab(demo: demo)
                    case 2:
                        codeTab(demo: demo)
                    default:
                        APISignaturesView(symbol: symbol)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Nonvisual / Reference only symbol
                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                        Text("detail.reference_only")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))

                    APISignaturesView(symbol: symbol)
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(symbol.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    favorites.toggleFavorite(symbol.id)
                }) {
                    Image(systemName: favorites.isFavorite(symbol.id) ? "star.fill" : "star")
                        .foregroundStyle(favorites.isFavorite(symbol.id) ? .yellow : .primary)
                }
            }
        }
        .onAppear {
            favorites.recordViewed(symbol.id)
            setupDemo()
        }
        .onChange(of: symbol.id) {
            favorites.recordViewed(symbol.id)
            setupDemo()
        }
    }

    private func setupDemo() {
        if let demoID = symbol.demoID, let provider = CatalogDemoRegistry.shared.provider(for: demoID) {
            self.demoProvider = provider
            self.playgroundState.reset(from: provider.parameters)
        } else {
            self.demoProvider = nil
        }
    }

    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(symbol.name)
                        .font(.title2)
                        .bold()

                    HStack(spacing: 6) {
                        Text(symbol.framework.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(symbol.framework == .swiftUI ? Color.blue.opacity(0.12) : Color.orange.opacity(0.12), in: Capsule())
                            .foregroundStyle(symbol.framework == .swiftUI ? Color.blue : Color.orange)

                        Text(symbol.kind.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let intro = symbol.availability.introduced {
                            Text("iOS \(intro.description)+")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Spacer()

                // Apple Documentation & HIG Links
                HStack(spacing: 8) {
                    if let docPath = symbol.documentationPath,
                       let url = DocumentationLinks.documentationURL(path: docPath) {
                        Link(destination: url) {
                            Label("link.apple_docs", systemImage: "arrow.up.right.square")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.12), in: Capsule())
                        }
                    }

                    if let higPath = symbol.higPath,
                       let url = DocumentationLinks.higURL(path: higPath) {
                        Link(destination: url) {
                            Label("link.hig", systemImage: "sparkles")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.12), in: Capsule())
                        }
                    }
                }
            }

            // Cross-framework related APIs
            if !symbol.related.isEmpty {
                HStack(spacing: 6) {
                    Text("detail.related")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(symbol.related, id: \.target) { rel in
                        NavigationLink(value: store.symbol(for: rel.target)) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.triangle.swap")
                                Text(rel.target)
                            }
                            .font(.caption2)
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.tintColor.opacity(0.12), in: Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
    }

    private func tabBar() -> some View {
        Picker("View Mode", selection: $selectedTab) {
            Text("tab.preview").tag(0)
            Text("tab.variants").tag(1)
            Text("tab.code").tag(2)
            Text("tab.api").tag(3)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func previewTab(demo: CatalogDemoProvider) -> some View {
        VStack(spacing: 0) {
            // Live Preview Canvas
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                demo.makePreview(state: playgroundState)
                    .padding()
            }
            .frame(minHeight: 180, maxHeight: 240)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.top, 8)

            // Parameter Inspector
            PlaygroundInspectorView(parameters: demo.parameters, state: playgroundState)
        }
    }

    private func variantsTab(demo: CatalogDemoProvider) -> some View {
        List {
            Section(header: Text("tab.variants")) {
                ForEach(demo.variants) { variant in
                    Button(action: {
                        playgroundState.apply(variant: variant)
                        selectedTab = 0
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizedStringKey(variant.titleKey))
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("variant.tap_to_apply")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "play.circle")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func codeTab(demo: CatalogDemoProvider) -> some View {
        CodeSnippetView(
            swiftUICode: demo.swiftUICode(state: playgroundState),
            uiKitCode: demo.uiKitCode(state: playgroundState)
        )
    }
}
