import SwiftUI
import CatalogModel

// MARK: - Menu Demo

public struct SwiftUIMenuDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Menu"
    public let titleKey = "demo.menu.title"
    public let familyID = "menus-actions"

    public let parameters: [DemoParameter] = [
        .text(key: "title", titleKey: "param.title", defaultValue: "Options"),
        .picker(key: "style", titleKey: "param.style", options: ["button", "borderlessButton"], defaultValue: "button"),
        .boolean(key: "showIcons", titleKey: "param.show_icons", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default"),
        DemoVariant(id: "noIcons", titleKey: "variant.no_icons", stateOverrides: ["showIcons": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let title = state.string(for: "title", default: "Options")
        let showIcons = state.bool(for: "showIcons", default: true)

        return AnyView(
            Menu(title) {
                Button(action: {}) {
                    if showIcons {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    } else {
                        Text("Duplicate")
                    }
                }
                Button(action: {}) {
                    if showIcons {
                        Label("Rename", systemImage: "pencil")
                    } else {
                        Text("Rename")
                    }
                }
                Menu("Sort By") {
                    Button("Name", action: {})
                    Button("Date", action: {})
                }
                Divider()
                Button(role: .destructive, action: {}) {
                    if showIcons {
                        Label("Delete", systemImage: "trash")
                    } else {
                        Text("Delete")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        Menu("Options") {
            Button("Duplicate", systemImage: "plus.square.on.square") {}
            Button("Rename", systemImage: "pencil") {}
            Menu("Sort By") {
                Button("Name") {}
                Button("Date") {}
            }
            Divider()
            Button("Delete", systemImage: "trash", role: .destructive) {}
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let duplicate = UIAction(title: "Duplicate", image: UIImage(systemName: "plus.square.on.square")) { _ in }
        let rename = UIAction(title: "Rename", image: UIImage(systemName: "pencil")) { _ in }
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in }

        let menu = UIMenu(title: "Options", children: [duplicate, rename, delete])
        let button = UIButton(type: .system)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        """
    }
}

// MARK: - ControlGroup Demo

public struct SwiftUIControlGroupDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.ControlGroup"
    public let titleKey = "demo.controlgroup.title"
    public let familyID = "menus-actions"

    public let parameters: [DemoParameter] = [
        .picker(key: "style", titleKey: "param.style", options: ["automatic", "compactMenu"], defaultValue: "automatic")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "automatic", titleKey: "variant.automatic", stateOverrides: ["style": AnySendable("automatic")]),
        DemoVariant(id: "compactMenu", titleKey: "variant.compact_menu", stateOverrides: ["style": AnySendable("compactMenu")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let style = state.string(for: "style", default: "automatic")

        let group = ControlGroup {
            Button(action: {}) {
                Label("Decrease", systemImage: "minus")
            }
            Button(action: {}) {
                Label("Increase", systemImage: "plus")
            }
            Button(action: {}) {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
        }

        return AnyView(
            VStack {
                if style == "compactMenu" {
                    group.controlGroupStyle(.compactMenu)
                } else {
                    group.controlGroupStyle(.automatic)
                }
            }
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let style = state.string(for: "style", default: "automatic")
        return """
        ControlGroup {
            Button("Decrease", systemImage: "minus") {}
            Button("Increase", systemImage: "plus") {}
            Button("Reset", systemImage: "arrow.counterclockwise") {}
        }
        .controlGroupStyle(.\(style))
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        // UIKit equivalent uses UIStackView of bordered buttons or a UISegmentedControl
        let stack = UIStackView(arrangedSubviews: [btn1, btn2, btn3])
        stack.axis = .horizontal
        stack.spacing = 1
        """
    }
}

// MARK: - ContextMenu Demo

public struct SwiftUIContextMenuDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.View.contextMenu"
    public let titleKey = "demo.contextmenu.title"
    public let familyID = "menus-actions"

    public let parameters: [DemoParameter] = [
        .text(key: "label", titleKey: "param.label", defaultValue: "Press and hold for menu")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let label = state.string(for: "label", default: "Press and hold for menu")

        return AnyView(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.gradient)
                .frame(width: 220, height: 100)
                .overlay(
                    Text(label)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(8)
                )
                .contextMenu {
                    Button(action: {}) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {}) {
                        Label("Favorite", systemImage: "star")
                    }
                    Divider()
                    Button(role: .destructive, action: {}) {
                        Label("Delete", systemImage: "trash")
                    }
                }
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        Text("Press and hold for menu")
            .contextMenu {
                Button("Share", systemImage: "square.and.arrow.up") {}
                Button("Favorite", systemImage: "star") {}
                Divider()
                Button("Delete", systemImage: "trash", role: .destructive) {}
            }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let interaction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(interaction)

        // in UIContextMenuInteractionDelegate:
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(actionProvider: { _ in
                UIMenu(children: [shareAction, favoriteAction])
            })
        }
        """
    }
}

// MARK: - ShareLink Demo

public struct SwiftUIShareLinkDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.ShareLink"
    public let titleKey = "demo.sharelink.title"
    public let familyID = "menus-actions"

    public let parameters: [DemoParameter] = [
        .text(key: "url", titleKey: "param.url", defaultValue: "https://developer.apple.com"),
        .text(key: "label", titleKey: "param.label", defaultValue: "Share Documentation")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let urlStr = state.string(for: "url", default: "https://developer.apple.com")
        let label = state.string(for: "label", default: "Share Documentation")
        let url = URL(string: urlStr) ?? URL(string: "https://developer.apple.com")!

        return AnyView(
            ShareLink(item: url) {
                Label(label, systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        ShareLink(item: URL(string: "https://developer.apple.com")!) {
            Label("Share Documentation", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.borderedProminent)
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let activityVC = UIActivityViewController(
            activityItems: [URL(string: "https://developer.apple.com")!],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
        """
    }
}
