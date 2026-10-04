import SwiftUI
import CatalogModel
#if canImport(UIKit)
import UIKit
#endif

// MARK: - UIAlertController Demo

public struct UIKitUIAlertControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIAlertController"
    public let titleKey = "demo.uialertcontroller.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(
            Button(action: {
                #if canImport(UIKit)
                let alert = UIAlertController(title: "Confirm Action", message: "Do you want to proceed with this UIKit alert?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                Self.topViewController()?.present(alert, animated: true)
                #endif
            }) {
                Label("Present UIAlertController", systemImage: "exclamationmark.bubble")
            }
            .buttonStyle(.borderedProminent)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        ".alert(\"Confirm Action\", isPresented: $showAlert) { ... }"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let alert = UIAlertController(title: "Confirm Action", message: "Do you want to proceed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        """
    }

    #if canImport(UIKit)
    static func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return nil }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        return top
    }
    #endif
}

// MARK: - UISheetPresentationController Demo

public struct UIKitUISheetPresentationControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UISheetPresentationController"
    public let titleKey = "demo.uisheetpresentationcontroller.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(
            Button(action: {
                #if canImport(UIKit)
                let vc = UIViewController()
                vc.view.backgroundColor = .systemBackground
                let label = UILabel()
                label.text = "UIKit UISheetPresentationController"
                label.font = .preferredFont(forTextStyle: .headline)
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                vc.view.addSubview(label)
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
                ])

                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                }
                UIKitUIAlertControllerDemo.topViewController()?.present(vc, animated: true)
                #endif
            }) {
                Label("Present UIKit Sheet", systemImage: "rectangle.portrait.and.arrow.forward")
            }
            .buttonStyle(.borderedProminent)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        ".sheet(isPresented: $show) { ... }.presentationDetents([.medium, .large])"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let sheetVC = UIViewController()
        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(sheetVC, animated: true)
        """
    }
}

// MARK: - UIPopoverPresentationController Demo

public struct UIKitUIPopoverPresentationControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIPopoverPresentationController"
    public let titleKey = "demo.uipopoverpresentationcontroller.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(
            Button(action: {
                #if canImport(UIKit)
                let vc = UIViewController()
                vc.view.backgroundColor = .systemBackground
                vc.modalPresentationStyle = .popover
                if let pop = vc.popoverPresentationController,
                   let top = UIKitUIAlertControllerDemo.topViewController() {
                    pop.sourceView = top.view
                    pop.sourceRect = CGRect(x: top.view.bounds.midX, y: top.view.bounds.midY, width: 0, height: 0)
                }
                UIKitUIAlertControllerDemo.topViewController()?.present(vc, animated: true)
                #endif
            }) {
                Label("Present UIPopover", systemImage: "bubble.middle.bottom")
            }
            .buttonStyle(.bordered)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        ".popover(isPresented: $show) { ... }"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let vc = UIViewController()
        vc.modalPresentationStyle = .popover
        if let pop = vc.popoverPresentationController {
            pop.sourceView = sender
        }
        present(vc, animated: true)
        """
    }
}

// MARK: - UIMenu Demo

public struct UIKitUIMenuDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIMenu"
    public let titleKey = "demo.uimenu.title"
    public let familyID = "menus-actions"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewHost { _ in
                let btn = UIButton(type: .system)
                btn.configuration = .borderedProminent()
                btn.configuration?.title = "Tap for UIMenu"
                let act1 = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in }
                let act2 = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in }
                btn.menu = UIMenu(title: "Actions", children: [act1, act2])
                btn.showsMenuAsPrimaryAction = true
                return btn
            }
            .frame(width: 180, height: 44)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "Menu(\"Actions\") { ... }"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let menu = UIMenu(title: "Actions", children: [act1, act2])
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        """
    }
}

// MARK: - UIAction Demo

public struct UIKitUIActionDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIAction"
    public let titleKey = "demo.uiaction.title"
    public let familyID = "menus-actions"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewHost { _ in
                let action = UIAction(title: "UIAction Handler", image: UIImage(systemName: "bolt.fill")) { _ in }
                let btn = UIButton(primaryAction: action)
                btn.configuration = .tinted()
                return btn
            }
            .frame(width: 200, height: 44)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "Button(\"Action\") { ... }"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let action = UIAction(title: "Tap Me") { action in
            print("Action executed")
        }
        let button = UIButton(primaryAction: action)
        """
    }
}

// MARK: - UIContextMenuInteraction Demo

public struct UIKitUIContextMenuInteractionDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIContextMenuInteraction"
    public let titleKey = "demo.uicontextmenuinteraction.title"
    public let familyID = "menus-actions"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewHost { _ in
                let box = UIView()
                box.backgroundColor = .systemIndigo
                box.layer.cornerRadius = 12
                let label = UILabel()
                label.text = "Long press for UIKit menu"
                label.textColor = .white
                label.font = .preferredFont(forTextStyle: .subheadline)
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                box.addSubview(label)
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: box.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: box.centerYAnchor)
                ])

                let delegate = ContextMenuDelegate()
                let interaction = UIContextMenuInteraction(delegate: delegate)
                box.addInteraction(interaction)
                objc_setAssociatedObject(box, "cmd", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return box
            }
            .frame(width: 220, height: 80)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        ".contextMenu { ... }"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let interaction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(interaction)
        """
    }
}

#if canImport(UIKit)
private final class ContextMenuDelegate: NSObject, UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { _ in
            UIMenu(children: [
                UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) { _ in },
                UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in }
            ])
        })
    }
}
#endif

// MARK: - UIActivityViewController Demo

public struct UIKitUIActivityViewControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIActivityViewController"
    public let titleKey = "demo.uiactivityviewcontroller.title"
    public let familyID = "menus-actions"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(
            Button(action: {
                #if canImport(UIKit)
                let av = UIActivityViewController(activityItems: [URL(string: "https://apple.com")!], applicationActivities: nil)
                UIKitUIAlertControllerDemo.topViewController()?.present(av, animated: true)
                #endif
            }) {
                Label("Present UIActivityViewController", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        "ShareLink(item: URL(string: \"https://apple.com\")!)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(av, animated: true)
        """
    }
}

// MARK: - UIDocumentPickerViewController Demo

public struct UIKitUIDocumentPickerViewControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIDocumentPickerViewController"
    public let titleKey = "demo.uidocumentpickerviewcontroller.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(
            Button(action: {
                #if canImport(UIKit)
                let dp = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
                UIKitUIAlertControllerDemo.topViewController()?.present(dp, animated: true)
                #endif
            }) {
                Label("Open Document Picker", systemImage: "folder")
            }
            .buttonStyle(.bordered)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        ".fileImporter(isPresented: $show, allowedContentTypes: [.item]) { ... }"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.delegate = self
        present(picker, animated: true)
        """
    }
}

// MARK: - UIColorPickerViewController Demo

public struct UIKitUIColorPickerViewControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIColorPickerViewController"
    public let titleKey = "demo.uicolorpickerviewcontroller.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(
            Button(action: {
                #if canImport(UIKit)
                let cp = UIColorPickerViewController()
                UIKitUIAlertControllerDemo.topViewController()?.present(cp, animated: true)
                #endif
            }) {
                Label("Open Color Picker", systemImage: "paintpalette")
            }
            .buttonStyle(.bordered)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        "ColorPicker(\"Color\", selection: $color)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let picker = UIColorPickerViewController()
        picker.delegate = self
        present(picker, animated: true)
        """
    }
}

// MARK: - UIFontPickerViewController Demo

public struct UIKitUIFontPickerViewControllerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIFontPickerViewController"
    public let titleKey = "demo.uifontpickerviewcontroller.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [DemoVariant(id: "default", titleKey: "variant.default")]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(
            Button(action: {
                #if canImport(UIKit)
                let fp = UIFontPickerViewController()
                UIKitUIAlertControllerDemo.topViewController()?.present(fp, animated: true)
                #endif
            }) {
                Label("Open Font Picker", systemImage: "textformat")
            }
            .buttonStyle(.bordered)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        "// SwiftUI uses custom font pickers or system font configurations"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let picker = UIFontPickerViewController()
        picker.delegate = self
        present(picker, animated: true)
        """
    }
}
