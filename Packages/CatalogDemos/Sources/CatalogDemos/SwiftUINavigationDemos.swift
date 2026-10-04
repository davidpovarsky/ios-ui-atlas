import SwiftUI
import CatalogModel

// MARK: - NavigationStack Demo

public struct SwiftUINavigationStackDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.NavigationStack"
    public let titleKey = "demo.navigationstack.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = [
        .text(key: "title", titleKey: "param.title", defaultValue: "NavigationStack")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let title = state.string(for: "title", default: "NavigationStack")

        return AnyView(
            NavigationStack {
                List {
                    NavigationLink("SwiftUI Components") {
                        Text("Detailed view for components")
                            .navigationTitle("Components")
                    }
                    NavigationLink("UIKit Equivalents") {
                        Text("Detailed view for UIKit")
                            .navigationTitle("UIKit")
                    }
                }
                .navigationTitle(title)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        NavigationStack {
            List {
                NavigationLink("SwiftUI Components", value: "swiftui")
                NavigationLink("UIKit Equivalents", value: "uikit")
            }
            .navigationTitle("NavigationStack")
            .navigationDestination(for: String.self) { value in
                DetailView(value)
            }
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let rootVC = ListViewController()
        let navController = UINavigationController(rootViewController: rootVC)
        """
    }
}

// MARK: - NavigationSplitView Demo

public struct SwiftUINavigationSplitViewDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.NavigationSplitView"
    public let titleKey = "demo.navigationsplitview.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = []

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(
            NavigationSplitView {
                List(["Content", "Layout", "Controls"], id: \.self) { cat in
                    Text(cat)
                }
                .navigationTitle("Sidebar")
            } detail: {
                Text("Select an item from the sidebar")
                    .foregroundStyle(.secondary)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        NavigationSplitView {
            List(categories, selection: $selectedCategory) { category in
                Text(category.name)
            }
            .navigationTitle("Sidebar")
        } detail: {
            DetailView(category: selectedCategory)
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let splitVC = UISplitViewController(style: .doubleColumn)
        splitVC.setViewController(sidebarVC, for: .primary)
        splitVC.setViewController(detailVC, for: .secondary)
        """
    }
}

// MARK: - NavigationLink Demo

public struct SwiftUINavigationLinkDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.NavigationLink"
    public let titleKey = "demo.navigationlink.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = [
        .text(key: "label", titleKey: "param.label", defaultValue: "Open Settings")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let label = state.string(for: "label", default: "Open Settings")

        return AnyView(
            NavigationStack {
                List {
                    NavigationLink(label) {
                        Text("Destination Content")
                            .navigationTitle("Settings")
                    }
                }
            }
            .frame(height: 140)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        NavigationLink("Open Settings") {
            SettingsView()
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        navigationController?.pushViewController(settingsVC, animated: true)
        """
    }
}

// MARK: - TabView Demo

public struct SwiftUITabViewDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.TabView"
    public let titleKey = "demo.tabview.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = [
        .picker(key: "style", titleKey: "param.style", options: ["automatic", "page"], defaultValue: "automatic")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "automatic", titleKey: "variant.automatic", stateOverrides: ["style": AnySendable("automatic")]),
        DemoVariant(id: "page", titleKey: "variant.page", stateOverrides: ["style": AnySendable("page")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let style = state.string(for: "style", default: "automatic")

        let view = TabView {
            Text("Explore Tab")
                .tabItem {
                    Label("Explore", systemImage: "sparkles")
                }
            Text("Search Tab")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            Text("Bookmarks Tab")
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
        }

        return AnyView(
            Group {
                if style == "page" {
                    view.tabViewStyle(.page)
                } else {
                    view.tabViewStyle(.automatic)
                }
            }
            .frame(height: 180)
            .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let style = state.string(for: "style", default: "automatic")
        return """
        TabView {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "sparkles") }
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
        .tabViewStyle(.\(style))
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let tabBar = UITabBarController()
        tabBar.viewControllers = [vc1, vc2]
        """
    }
}

// MARK: - Toolbar Demo

public struct SwiftUIToolbarDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Toolbar"
    public let titleKey = "demo.toolbar.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = []

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(
            NavigationStack {
                Text("Canvas Preview")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {}
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Edit", systemImage: "square.and.pencil") {}
                        }
                    }
                    .navigationTitle("Editor")
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {}
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit", systemImage: "square.and.pencil") {}
            }
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain, target: self, action: #selector(filter)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain, target: self, action: #selector(edit)
        )
        """
    }
}

// MARK: - Searchable Demo

public struct SwiftUISearchableDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.View.searchable"
    public let titleKey = "demo.searchable.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = [
        .text(key: "prompt", titleKey: "param.prompt", defaultValue: "Search symbols...")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let prompt = state.string(for: "prompt", default: "Search symbols...")

        return AnyView(
            SearchableDemoView(prompt: prompt)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let prompt = state.string(for: "prompt", default: "Search symbols...")
        return """
        @State private var searchText = ""

        NavigationStack {
            List(filteredItems) { item in
                Text(item.name)
            }
            .searchable(text: $searchText, prompt: "\(prompt)")
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search symbols..."
        navigationItem.searchController = searchController
        """
    }
}

private struct SearchableDemoView: View {
    let prompt: String
    @State private var query = ""
    let allSymbols = ["Button", "Toggle", "Slider", "DatePicker", "List", "NavigationStack", "Sheet"]

    var filtered: [String] {
        if query.isEmpty { return allSymbols }
        return allSymbols.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List(filtered, id: \.self) { sym in
                Text(sym)
            }
            .navigationTitle("Symbols")
            .searchable(text: $query, prompt: prompt)
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
    }
}
