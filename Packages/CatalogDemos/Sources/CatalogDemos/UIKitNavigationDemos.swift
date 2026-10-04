import SwiftUI
import CatalogModel
#if canImport(UIKit)
import UIKit
#endif

// MARK: - UISearchBar Demo

public struct UIKitUISearchBarDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UISearchBar"
    public let titleKey = "demo.uisearchbar.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewHost { _ in
                let sb = UISearchBar()
                sb.placeholder = "Search in UIKit"
                sb.searchBarStyle = .minimal
                return sb
            }
            .frame(width: 260, height: 44)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        ".searchable(text: $query)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search in UIKit"
        searchBar.searchBarStyle = .minimal
        """
    }
}

// MARK: - UISearchController Demo

public struct UIKitUISearchControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UISearchController"
    public let titleKey = "demo.uisearchcontroller.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewHost { _ in
                let sc = UISearchController(searchResultsController: nil)
                sc.searchBar.placeholder = "UISearchController Integration"
                return sc.searchBar
            }
            .frame(width: 260, height: 44)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        ".searchable(text: $query, prompt: \"Search...\")"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        navigationItem.searchController = sc
        """
    }
}

// MARK: - UINavigationController Demo

public struct UIKitUINavigationControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UINavigationController"
    public let titleKey = "demo.uinavigationcontroller.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewControllerHost { _ in
                let root = UIViewController()
                root.title = "UIKit Navigation"
                let nav = UINavigationController(rootViewController: root)
                nav.navigationBar.prefersLargeTitles = true
                return nav
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "NavigationStack { ... }"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let nav = UINavigationController(rootViewController: rootVC)
        nav.navigationBar.prefersLargeTitles = true
        """
    }
}

// MARK: - UITabBarController Demo

public struct UIKitUITabBarControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UITabBarController"
    public let titleKey = "demo.uitabbarcontroller.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewControllerHost { _ in
                let tab = UITabBarController()
                let vc1 = UIViewController()
                vc1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
                let vc2 = UIViewController()
                vc2.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)
                tab.viewControllers = [vc1, vc2]
                return tab
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "TabView { ... }"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let tab = UITabBarController()
        tab.viewControllers = [vc1, vc2]
        """
    }
}

// MARK: - UISplitViewController Demo

public struct UIKitUISplitViewControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UISplitViewController"
    public let titleKey = "demo.uisplitviewcontroller.title"
    public let familyID = "navigation-search"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewControllerHost { _ in
                let split = UISplitViewController(style: .doubleColumn)
                let pri = UIViewController()
                pri.title = "Master"
                let sec = UIViewController()
                sec.title = "Detail"
                split.setViewController(pri, for: .primary)
                split.setViewController(sec, for: .secondary)
                return split
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "NavigationSplitView { ... } detail: { ... }"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let split = UISplitViewController(style: .doubleColumn)
        split.setViewController(primaryVC, for: .primary)
        split.setViewController(secondaryVC, for: .secondary)
        """
    }
}
