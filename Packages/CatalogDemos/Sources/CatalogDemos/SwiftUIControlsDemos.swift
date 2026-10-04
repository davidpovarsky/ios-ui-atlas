import SwiftUI
import CatalogModel

// MARK: - SwiftUI Button Demo

public struct SwiftUIButtonDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Button"
    public let titleKey = "demo.button.title"
    public let familyID = "menus-actions"

    public let parameters: [DemoParameter] = [
        .text(key: "title", titleKey: "param.title", defaultValue: "Continue"),
        .picker(key: "style", titleKey: "param.style", options: ["automatic", "bordered", "borderedProminent", "borderless", "plain"], defaultValue: "borderedProminent"),
        .picker(key: "role", titleKey: "param.role", options: ["none", "cancel", "destructive"], defaultValue: "none"),
        .picker(key: "size", titleKey: "param.control_size", options: ["mini", "small", "regular", "large", "extraLarge"], defaultValue: "regular"),
        .boolean(key: "enabled", titleKey: "param.enabled", defaultValue: true),
        .picker(key: "tint", titleKey: "param.tint", options: ["blue", "indigo", "mint", "orange", "pink", "purple", "red"], defaultValue: "blue")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default"),
        DemoVariant(id: "bordered", titleKey: "variant.bordered", stateOverrides: ["style": AnySendable("bordered")]),
        DemoVariant(id: "prominent", titleKey: "variant.prominent", stateOverrides: ["style": AnySendable("borderedProminent")]),
        DemoVariant(id: "destructive", titleKey: "variant.destructive", stateOverrides: ["role": AnySendable("destructive"), "style": AnySendable("bordered")]),
        DemoVariant(id: "disabled", titleKey: "variant.disabled", stateOverrides: ["enabled": AnySendable(false)]),
        DemoVariant(id: "large", titleKey: "variant.large", stateOverrides: ["size": AnySendable("large"), "style": AnySendable("borderedProminent")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let title = state.string(for: "title", default: "Continue")
        let style = state.string(for: "style", default: "borderedProminent")
        let roleStr = state.string(for: "role", default: "none")
        let sizeStr = state.string(for: "size", default: "regular")
        let enabled = state.bool(for: "enabled", default: true)
        let tint = tintColor(state.string(for: "tint", default: "blue"))

        let role: ButtonRole? = roleStr == "destructive" ? .destructive : (roleStr == "cancel" ? .cancel : nil)

        return AnyView(
            Button(role: role, action: {}) {
                Text(title)
            }
            .buttonStyle(resolveStyle(style))
            .controlSize(resolveSize(sizeStr))
            .tint(tint)
            .disabled(!enabled)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let title = state.string(for: "title", default: "Continue")
        let style = state.string(for: "style", default: "borderedProminent")
        let role = state.string(for: "role", default: "none")
        let size = state.string(for: "size", default: "regular")
        let enabled = state.bool(for: "enabled", default: true)
        let tint = state.string(for: "tint", default: "blue")

        var code = ""
        if role != "none" {
            code += "Button(\"\(title)\", role: .\(role)) {\n    // action\n}\n"
        } else {
            code += "Button(\"\(title)\") {\n    // action\n}\n"
        }
        if style != "automatic" { code += ".buttonStyle(.\(style))\n" }
        if size != "regular" { code += ".controlSize(.\(size))\n" }
        if tint != "blue" { code += ".tint(.\(tint))\n" }
        if !enabled { code += ".disabled(true)\n" }
        return code.trimmingCharacters(in: .newlines)
    }

    public func uiKitCode(state: DemoState) -> String? {
        let title = state.string(for: "title", default: "Continue")
        let style = state.string(for: "style", default: "borderedProminent")
        let enabled = state.bool(for: "enabled", default: true)

        let configType = style == "borderedProminent" ? "filled()" : (style == "bordered" ? "bordered()" : "plain()")
        return """
        var configuration = UIButton.Configuration.\(configType)
        configuration.title = "\(title)"
        let button = UIButton(configuration: configuration)
        button.isEnabled = \(enabled)
        """
    }

    private func resolveStyle(_ name: String) -> AnyButtonStyle {
        switch name {
        case "bordered": return AnyButtonStyle(BorderedButtonStyle())
        case "borderedProminent": return AnyButtonStyle(BorderedProminentButtonStyle())
        case "borderless": return AnyButtonStyle(BorderlessButtonStyle())
        case "plain": return AnyButtonStyle(PlainButtonStyle())
        default: return AnyButtonStyle(AutomaticButtonStyle())
        }
    }

    private func resolveSize(_ name: String) -> ControlSize {
        switch name {
        case "mini": return .mini
        case "small": return .small
        case "large": return .large
        case "extraLarge": return .extraLarge
        default: return .regular
        }
    }

    private func tintColor(_ name: String) -> Color {
        switch name {
        case "indigo": return .indigo
        case "mint": return .mint
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "red": return .red
        default: return .blue
        }
    }
}

// Wrapper to type-erase ButtonStyle
struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView
    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }
    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - SwiftUI Toggle Demo

public struct SwiftUIToggleDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Toggle"
    public let titleKey = "demo.toggle.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .text(key: "title", titleKey: "param.title", defaultValue: "Airplane Mode"),
        .picker(key: "style", titleKey: "param.style", options: ["switch", "button"], defaultValue: "switch"),
        .boolean(key: "isOn", titleKey: "param.is_on", defaultValue: true),
        .boolean(key: "enabled", titleKey: "param.enabled", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "on", titleKey: "variant.on", stateOverrides: ["isOn": AnySendable(true)]),
        DemoVariant(id: "off", titleKey: "variant.off", stateOverrides: ["isOn": AnySendable(false)]),
        DemoVariant(id: "button", titleKey: "variant.button_style", stateOverrides: ["style": AnySendable("button")]),
        DemoVariant(id: "disabled", titleKey: "variant.disabled", stateOverrides: ["enabled": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let title = state.string(for: "title", default: "Airplane Mode")
        let style = state.string(for: "style", default: "switch")
        let enabled = state.bool(for: "enabled", default: true)

        let binding = Binding<Bool>(
            get: { state.bool(for: "isOn", default: true) },
            set: { state.booleans["isOn"] = $0 }
        )

        return AnyView(
            VStack {
                if style == "button" {
                    Toggle(title, isOn: binding)
                        .toggleStyle(.button)
                        .disabled(!enabled)
                } else {
                    Toggle(title, isOn: binding)
                        .toggleStyle(.switch)
                        .disabled(!enabled)
                }
            }
            .frame(maxWidth: 280)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let title = state.string(for: "title", default: "Airplane Mode")
        let style = state.string(for: "style", default: "switch")
        let enabled = state.bool(for: "enabled", default: true)

        var code = "@State private var isOn = true\n\nToggle(\"\(title)\", isOn: $isOn)\n"
        if style == "button" { code += ".toggleStyle(.button)\n" }
        if !enabled { code += ".disabled(true)\n" }
        return code.trimmingCharacters(in: .newlines)
    }

    public func uiKitCode(state: DemoState) -> String? {
        let enabled = state.bool(for: "enabled", default: true)
        return """
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.isEnabled = \(enabled)
        toggle.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        """
    }
}

// MARK: - SwiftUI Slider Demo

public struct SwiftUISliderDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Slider"
    public let titleKey = "demo.slider.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .slider(key: "value", titleKey: "param.value", min: 0, max: 100, defaultValue: 50),
        .boolean(key: "showLabels", titleKey: "param.show_labels", defaultValue: true),
        .boolean(key: "step", titleKey: "param.step", defaultValue: false),
        .boolean(key: "enabled", titleKey: "param.enabled", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default"),
        DemoVariant(id: "stepped", titleKey: "variant.stepped", stateOverrides: ["step": AnySendable(true)]),
        DemoVariant(id: "disabled", titleKey: "variant.disabled", stateOverrides: ["enabled": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let showLabels = state.bool(for: "showLabels", default: true)
        let useStep = state.bool(for: "step", default: false)
        let enabled = state.bool(for: "enabled", default: true)

        let binding = Binding<Double>(
            get: { state.double(for: "value", default: 50) },
            set: { state.doubles["value"] = $0 }
        )

        return AnyView(
            VStack(spacing: 12) {
                if showLabels {
                    Slider(
                        value: binding,
                        in: 0...100,
                        step: useStep ? 10 : 1
                    ) {
                        Text("Volume")
                    } minimumValueLabel: {
                        Image(systemName: "speaker.fill")
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3.fill")
                    }
                } else {
                    Slider(value: binding, in: 0...100, step: useStep ? 10 : 1)
                }
                Text("\(Int(state.double(for: "value", default: 50)))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 280)
            .disabled(!enabled)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let useStep = state.bool(for: "step", default: false)
        let showLabels = state.bool(for: "showLabels", default: true)

        if showLabels {
            return """
            @State private var value = 50.0

            Slider(value: $value, in: 0...100\(useStep ? ", step: 10" : "")) {
                Text("Volume")
            } minimumValueLabel: {
                Image(systemName: "speaker.fill")
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.3.fill")
            }
            """
        } else {
            return """
            @State private var value = 50.0

            Slider(value: $value, in: 0...100\(useStep ? ", step: 10" : ""))
            """
        }
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 100.0
        slider.value = 50.0
        slider.minimumValueImage = UIImage(systemName: "speaker.fill")
        slider.maximumValueImage = UIImage(systemName: "speaker.wave.3.fill")
        """
    }
}

// MARK: - SwiftUI Stepper Demo

public struct SwiftUIStepperDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Stepper"
    public let titleKey = "demo.stepper.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .stepper(key: "value", titleKey: "param.value", min: 0, max: 20, defaultValue: 2),
        .text(key: "label", titleKey: "param.label", defaultValue: "Guests"),
        .boolean(key: "enabled", titleKey: "param.enabled", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default"),
        DemoVariant(id: "zero", titleKey: "variant.zero", stateOverrides: ["value": AnySendable(0)]),
        DemoVariant(id: "disabled", titleKey: "variant.disabled", stateOverrides: ["enabled": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let label = state.string(for: "label", default: "Guests")
        let enabled = state.bool(for: "enabled", default: true)
        let binding = Binding<Int>(
            get: { state.int(for: "value", default: 2) },
            set: { state.ints["value"] = $0 }
        )

        return AnyView(
            Stepper("\(label): \(binding.wrappedValue)", value: binding, in: 0...20)
                .frame(maxWidth: 260)
                .disabled(!enabled)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        @State private var value = 2

        Stepper("Guests: \\(value)", value: $value, in: 0...20)
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 20
        stepper.value = 2
        """
    }
}

// MARK: - SwiftUI Picker Demo

public struct SwiftUIPickerDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Picker"
    public let titleKey = "demo.picker.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .picker(key: "style", titleKey: "param.style", options: ["menu", "segmented", "wheel", "navigationLink"], defaultValue: "segmented"),
        .picker(key: "selected", titleKey: "param.selected", options: ["Daily", "Weekly", "Monthly"], defaultValue: "Daily")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "segmented", titleKey: "variant.segmented", stateOverrides: ["style": AnySendable("segmented")]),
        DemoVariant(id: "menu", titleKey: "variant.menu", stateOverrides: ["style": AnySendable("menu")]),
        DemoVariant(id: "wheel", titleKey: "variant.wheel", stateOverrides: ["style": AnySendable("wheel")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let style = state.string(for: "style", default: "segmented")
        let binding = Binding<String>(
            get: { state.string(for: "selected", default: "Daily") },
            set: { state.strings["selected"] = $0 }
        )
        let options = ["Daily", "Weekly", "Monthly"]

        let picker = Picker("Frequency", selection: binding) {
            ForEach(options, id: \.self) { opt in
                Text(opt).tag(opt)
            }
        }

        return AnyView(
            VStack {
                switch style {
                case "menu":
                    picker.pickerStyle(.menu)
                case "wheel":
                    picker.pickerStyle(.wheel).frame(height: 120)
                case "navigationLink":
                    picker.pickerStyle(.navigationLink)
                default:
                    picker.pickerStyle(.segmented)
                }
            }
            .frame(maxWidth: 280)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let style = state.string(for: "style", default: "segmented")
        return """
        @State private var frequency = "Daily"
        let options = ["Daily", "Weekly", "Monthly"]

        Picker("Frequency", selection: $frequency) {
            ForEach(options, id: \\.self) {
                Text($0)
            }
        }
        .pickerStyle(.\(style))
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        let style = state.string(for: "style", default: "segmented")
        if style == "segmented" {
            return """
            let segmented = UISegmentedControl(items: ["Daily", "Weekly", "Monthly"])
            segmented.selectedSegmentIndex = 0
            """
        } else {
            return """
            let pickerView = UIPickerView()
            pickerView.dataSource = self
            pickerView.delegate = self
            """
        }
    }
}

// MARK: - SwiftUI DatePicker Demo

public struct SwiftUIDatePickerDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.DatePicker"
    public let titleKey = "demo.datepicker.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .picker(key: "style", titleKey: "param.style", options: ["compact", "graphical", "wheel"], defaultValue: "compact"),
        .boolean(key: "includeTime", titleKey: "param.include_time", defaultValue: false)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "compact", titleKey: "variant.compact", stateOverrides: ["style": AnySendable("compact")]),
        DemoVariant(id: "graphical", titleKey: "variant.graphical", stateOverrides: ["style": AnySendable("graphical")]),
        DemoVariant(id: "withTime", titleKey: "variant.with_time", stateOverrides: ["includeTime": AnySendable(true)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let style = state.string(for: "style", default: "compact")
        let includeTime = state.bool(for: "includeTime", default: false)

        let binding = Binding<Date>(
            get: { Date() },
            set: { _ in }
        )

        let components: DatePickerComponents = includeTime ? [.date, .hourAndMinute] : [.date]

        let picker = DatePicker("Event Date", selection: binding, displayedComponents: components)

        return AnyView(
            VStack {
                switch style {
                case "graphical": picker.datePickerStyle(.graphical)
                case "wheel": picker.datePickerStyle(.wheel).frame(height: 140)
                default: picker.datePickerStyle(.compact)
                }
            }
            .frame(maxWidth: 320)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let style = state.string(for: "style", default: "compact")
        let includeTime = state.bool(for: "includeTime", default: false)
        return """
        @State private var date = Date()

        DatePicker(
            "Event Date",
            selection: $date,
            displayedComponents: \(includeTime ? "[.date, .hourAndMinute]" : "[.date]")
        )
        .datePickerStyle(.\(style))
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        let includeTime = state.bool(for: "includeTime", default: false)
        return """
        let picker = UIDatePicker()
        picker.datePickerMode = \(includeTime ? ".dateAndTime" : ".date")
        picker.preferredDatePickerStyle = .compact
        """
    }
}

// MARK: - SwiftUI ColorPicker Demo

public struct SwiftUIColorPickerDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.ColorPicker"
    public let titleKey = "demo.colorpicker.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .boolean(key: "supportsOpacity", titleKey: "param.supports_opacity", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "withOpacity", titleKey: "variant.with_opacity", stateOverrides: ["supportsOpacity": AnySendable(true)]),
        DemoVariant(id: "noOpacity", titleKey: "variant.no_opacity", stateOverrides: ["supportsOpacity": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let supportsOpacity = state.bool(for: "supportsOpacity", default: true)
        let binding = Binding<Color>(
            get: { .blue },
            set: { _ in }
        )

        return AnyView(
            ColorPicker("Accent Color", selection: binding, supportsOpacity: supportsOpacity)
                .frame(maxWidth: 260)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let supportsOpacity = state.bool(for: "supportsOpacity", default: true)
        return """
        @State private var selectedColor = Color.blue

        ColorPicker("Accent Color", selection: $selectedColor, supportsOpacity: \(supportsOpacity))
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let picker = UIColorPickerViewController()
        picker.selectedColor = .systemBlue
        picker.supportsAlpha = true
        present(picker, animated: true)
        """
    }
}

// MARK: - SwiftUI TextField Demo

public struct SwiftUITextFieldDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.TextField"
    public let titleKey = "demo.textfield.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .text(key: "placeholder", titleKey: "param.placeholder", defaultValue: "Email address"),
        .picker(key: "style", titleKey: "param.style", options: ["plain", "roundedBorder"], defaultValue: "roundedBorder"),
        .boolean(key: "clearButton", titleKey: "param.clear_button", defaultValue: false)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "rounded", titleKey: "variant.rounded", stateOverrides: ["style": AnySendable("roundedBorder")]),
        DemoVariant(id: "plain", titleKey: "variant.plain", stateOverrides: ["style": AnySendable("plain")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let placeholder = state.string(for: "placeholder", default: "Email address")
        let style = state.string(for: "style", default: "roundedBorder")
        let binding = Binding<String>(
            get: { state.string(for: "text", default: "") },
            set: { state.strings["text"] = $0 }
        )

        let field = TextField(placeholder, text: binding)

        return AnyView(
            VStack {
                if style == "roundedBorder" {
                    field.textFieldStyle(.roundedBorder)
                } else {
                    field.textFieldStyle(.plain)
                }
            }
            .frame(maxWidth: 280)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let placeholder = state.string(for: "placeholder", default: "Email address")
        let style = state.string(for: "style", default: "roundedBorder")
        return """
        @State private var text = ""

        TextField("\(placeholder)", text: $text)
            .textFieldStyle(.\(style))
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        let placeholder = state.string(for: "placeholder", default: "Email address")
        return """
        let textField = UITextField()
        textField.placeholder = "\(placeholder)"
        textField.borderStyle = .roundedRect
        """
    }
}

// MARK: - SwiftUI SecureField Demo

public struct SwiftUISecureFieldDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.SecureField"
    public let titleKey = "demo.securefield.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .text(key: "placeholder", titleKey: "param.placeholder", defaultValue: "Password")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let placeholder = state.string(for: "placeholder", default: "Password")
        let binding = Binding<String>(
            get: { state.string(for: "text", default: "") },
            set: { state.strings["text"] = $0 }
        )

        return AnyView(
            SecureField(placeholder, text: binding)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 280)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let placeholder = state.string(for: "placeholder", default: "Password")
        return """
        @State private var password = ""

        SecureField("\(placeholder)", text: $password)
            .textFieldStyle(.roundedBorder)
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        """
    }
}

// MARK: - SwiftUI TextEditor Demo

public struct SwiftUITextEditorDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.TextEditor"
    public let titleKey = "demo.texteditor.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .boolean(key: "scrollDismissesKeyboard", titleKey: "param.scroll_dismiss", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let binding = Binding<String>(
            get: { state.string(for: "text", default: "Add notes or comments here...") },
            set: { state.strings["text"] = $0 }
        )

        return AnyView(
            TextEditor(text: binding)
                .frame(height: 120)
                .padding(4)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
                .frame(maxWidth: 300)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        @State private var text = "Add notes here..."

        TextEditor(text: $text)
            .frame(height: 120)
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let textView = UITextView()
        textView.text = "Add notes here..."
        textView.font = .preferredFont(forTextStyle: .body)
        """
    }
}
