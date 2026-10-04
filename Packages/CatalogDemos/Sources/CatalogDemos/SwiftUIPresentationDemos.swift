import SwiftUI
import CatalogModel

// MARK: - Sheet Demo

public struct SwiftUISheetDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.View.sheet"
    public let titleKey = "demo.sheet.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = [
        .picker(key: "detent", titleKey: "param.detent", options: ["medium", "large", "both"], defaultValue: "both"),
        .boolean(key: "showIndicator", titleKey: "param.drag_indicator", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "medium", titleKey: "variant.medium", stateOverrides: ["detent": AnySendable("medium")]),
        DemoVariant(id: "large", titleKey: "variant.large", stateOverrides: ["detent": AnySendable("large")]),
        DemoVariant(id: "both", titleKey: "variant.both_detents", stateOverrides: ["detent": AnySendable("both")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let detent = state.string(for: "detent", default: "both")
        let indicator = state.bool(for: "showIndicator", default: true)

        return AnyView(
            SheetHostView(detent: detent, showIndicator: indicator)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let detent = state.string(for: "detent", default: "both")
        let detentCode = detent == "medium" ? "[.medium]" : (detent == "large" ? "[.large]" : "[.medium, .large]")
        return """
        @State private var isPresented = false

        Button("Present Sheet") {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            VStack {
                Text("Native Sheet")
                    .font(.headline)
            }
            .presentationDetents(\(detentCode))
            .presentationDragIndicator(.visible)
        }
        """
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

private struct SheetHostView: View {
    let detent: String
    let showIndicator: Bool
    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented = true }) {
            Label("Present Sheet", systemImage: "rectangle.portrait.and.arrow.forward")
        }
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $isPresented) {
            VStack(spacing: 16) {
                Text("Native SwiftUI Sheet")
                    .font(.title2).bold()
                Text("Interactive detents and native grabber behavior.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("Dismiss") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .presentationDetents(resolveDetents(detent))
            .presentationDragIndicator(showIndicator ? .visible : .hidden)
        }
    }

    private func resolveDetents(_ mode: String) -> Set<PresentationDetent> {
        switch mode {
        case "medium": [.medium]
        case "large": [.large]
        default: [.medium, .large]
        }
    }
}

// MARK: - FullScreenCover Demo

public struct SwiftUIFullScreenCoverDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.View.fullScreenCover"
    public let titleKey = "demo.fullscreencover.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = []

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(FullScreenCoverHostView())
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        @State private var isPresented = false

        Button("Present Full Screen") {
            isPresented = true
        }
        .fullScreenCover(isPresented: $isPresented) {
            ModalContentView()
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let vc = UIViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        """
    }
}

private struct FullScreenCoverHostView: View {
    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented = true }) {
            Label("Present Full Screen Cover", systemImage: "arrow.up.left.and.arrow.down.right")
        }
        .buttonStyle(.borderedProminent)
        .fullScreenCover(isPresented: $isPresented) {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Full Screen Cover")
                        .font(.largeTitle).bold().foregroundStyle(.white)
                    Button("Dismiss") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

// MARK: - Popover Demo

public struct SwiftUIPopoverDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.View.popover"
    public let titleKey = "demo.popover.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = []

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(PopoverHostView())
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        @State private var isPresented = false

        Button("Show Popover") {
            isPresented = true
        }
        .popover(isPresented: $isPresented) {
            Text("Popover Content")
                .padding()
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let popoverVC = UIViewController()
        popoverVC.modalPresentationStyle = .popover
        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = sourceButton
        }
        present(popoverVC, animated: true)
        """
    }
}

private struct PopoverHostView: View {
    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented = true }) {
            Label("Show Popover", systemImage: "bubble.middle.bottom")
        }
        .buttonStyle(.bordered)
        .popover(isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Native Popover")
                    .font(.headline)
                Text("Adapts to a sheet on compact iPhone and floating arrow on iPad.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(width: 240)
        }
    }
}

// MARK: - Alert Demo

public struct SwiftUIAlertDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.View.alert"
    public let titleKey = "demo.alert.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = [
        .text(key: "title", titleKey: "param.title", defaultValue: "Discard Changes?"),
        .text(key: "message", titleKey: "param.message", defaultValue: "Any unsaved edits will be lost permanently.")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let title = state.string(for: "title", default: "Discard Changes?")
        let message = state.string(for: "message", default: "Any unsaved edits will be lost permanently.")

        return AnyView(
            AlertHostView(title: title, message: message)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        @State private var showAlert = false

        Button("Show Alert") {
            showAlert = true
        }
        .alert("Discard Changes?", isPresented: $showAlert) {
            Button("Discard", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Any unsaved edits will be lost permanently.")
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let alert = UIAlertController(
            title: "Discard Changes?",
            message: "Any unsaved edits will be lost permanently.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        """
    }
}

private struct AlertHostView: View {
    let title: String
    let message: String
    @State private var showAlert = false

    var body: some View {
        Button(action: { showAlert = true }) {
            Label("Show Alert", systemImage: "exclamationmark.triangle")
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .alert(title, isPresented: $showAlert) {
            Button("Discard", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(message)
        }
    }
}

// MARK: - ConfirmationDialog Demo

public struct SwiftUIConfirmationDialogDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.View.confirmationDialog"
    public let titleKey = "demo.confirmationdialog.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = [
        .text(key: "title", titleKey: "param.title", defaultValue: "Delete Account")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let title = state.string(for: "title", default: "Delete Account")

        return AnyView(
            ConfirmationDialogHostView(title: title)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        @State private var showDialog = false

        Button("Delete Account") {
            showDialog = true
        }
        .confirmationDialog("Delete Account", isPresented: $showDialog) {
            Button("Delete Permanently", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let sheet = UIAlertController(title: "Delete Account", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Delete Permanently", style: .destructive))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
        """
    }
}

private struct ConfirmationDialogHostView: View {
    let title: String
    @State private var showDialog = false

    var body: some View {
        Button(action: { showDialog = true }) {
            Label("Confirmation Dialog", systemImage: "ellipsis.circle")
        }
        .buttonStyle(.bordered)
        .confirmationDialog(title, isPresented: $showDialog) {
            Button("Delete Permanently", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        }
    }
}

// MARK: - Inspector Demo

public struct SwiftUIInspectorDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.View.inspector"
    public let titleKey = "demo.inspector.title"
    public let familyID = "presentation"

    public let parameters: [DemoParameter] = []

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(InspectorHostView())
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        @State private var isShowingInspector = false

        ContentView()
            .inspector(isPresented: $isShowingInspector) {
                InspectorContent()
            }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let splitVC = UISplitViewController(style: .tripleColumn)
        splitVC.setViewController(inspectorVC, for: .supplementary)
        """
    }
}

private struct InspectorHostView: View {
    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented.toggle() }) {
            Label("Toggle Inspector", systemImage: "sidebar.right")
        }
        .buttonStyle(.borderedProminent)
        .inspector(isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Inspector Panel")
                    .font(.headline)
                Divider()
                Toggle("Auto-save", isOn: .constant(true))
                Toggle("Show grid", isOn: .constant(false))
                Spacer()
            }
            .padding()
        }
    }
}
