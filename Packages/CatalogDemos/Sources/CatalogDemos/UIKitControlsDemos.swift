import SwiftUI
import CatalogModel
#if canImport(UIKit)
import UIKit
#endif

// MARK: - UIButton Demo

public struct UIKitUIButtonDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIButton"
    public let titleKey = "demo.uibutton.title"
    public let familyID = "menus-actions"

    public let parameters: [DemoParameter] = [
        .text(key: "title", titleKey: "param.title", defaultValue: "Continue"),
        .picker(key: "style", titleKey: "param.style", options: ["filled", "bordered", "borderedProminent", "plain"], defaultValue: "filled"),
        .boolean(key: "enabled", titleKey: "param.enabled", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "filled", titleKey: "variant.filled", stateOverrides: ["style": AnySendable("filled")]),
        DemoVariant(id: "bordered", titleKey: "variant.bordered", stateOverrides: ["style": AnySendable("bordered")]),
        DemoVariant(id: "disabled", titleKey: "variant.disabled", stateOverrides: ["enabled": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        let title = state.string(for: "title", default: "Continue")
        let style = state.string(for: "style", default: "filled")
        let enabled = state.bool(for: "enabled", default: true)

        return AnyView(
            UIKitViewHost {
                let btn = UIButton(type: .system)
                btn.configuration = Self.makeConfig(style: style, title: title)
                btn.isEnabled = enabled
                return btn
            }
            .frame(width: 160, height: 44)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    #if canImport(UIKit)
    private static func makeConfig(style: String, title: String) -> UIButton.Configuration {
        var config: UIButton.Configuration
        switch style {
        case "bordered": config = .bordered()
        case "borderedProminent":
            config = .filled()
            config.baseBackgroundColor = .systemIndigo
        case "plain": config = .plain()
        default: config = .filled()
        }
        config.title = title
        config.cornerStyle = .medium
        return config
    }
    #endif

    public func swiftUICode(state: DemoState) -> String {
        """
        Button("Continue") {}
            .buttonStyle(.borderedProminent)
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        let title = state.string(for: "title", default: "Continue")
        let style = state.string(for: "style", default: "filled")
        return """
        var config = UIButton.Configuration.\(style)()
        config.title = "\(title)"
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        """
    }
}

// MARK: - UISwitch Demo

public struct UIKitUISwitchDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UISwitch"
    public let titleKey = "demo.uiswitch.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .boolean(key: "isOn", titleKey: "param.is_on", defaultValue: true),
        .boolean(key: "enabled", titleKey: "param.enabled", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "on", titleKey: "variant.on", stateOverrides: ["isOn": AnySendable(true)]),
        DemoVariant(id: "off", titleKey: "variant.off", stateOverrides: ["isOn": AnySendable(false)]),
        DemoVariant(id: "disabled", titleKey: "variant.disabled", stateOverrides: ["enabled": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        let isOn = state.bool(for: "isOn", default: true)
        let enabled = state.bool(for: "enabled", default: true)

        return AnyView(
            UIKitViewHost {
                let sw = UISwitch()
                sw.isOn = isOn
                sw.isEnabled = enabled
                return sw
            }
            .frame(width: 60, height: 35)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "Toggle(\"Airplane Mode\", isOn: $isOn)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        let isOn = state.bool(for: "isOn", default: true)
        return """
        let toggle = UISwitch()
        toggle.isOn = \(isOn)
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        """
    }
}

// MARK: - UISlider Demo

public struct UIKitUISliderDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UISlider"
    public let titleKey = "demo.uislider.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .slider(key: "value", titleKey: "param.value", min: 0.0, max: 100.0, defaultValue: 50.0),
        .boolean(key: "enabled", titleKey: "param.enabled", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default"),
        DemoVariant(id: "disabled", titleKey: "variant.disabled", stateOverrides: ["enabled": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        let val = Float(state.double(for: "value", default: 50.0))
        let enabled = state.bool(for: "enabled", default: true)

        return AnyView(
            UIKitViewHost {
                let slider = UISlider()
                slider.minimumValue = 0.0
                slider.maximumValue = 100.0
                slider.value = val
                slider.isEnabled = enabled
                return slider
            }
            .frame(width: 240, height: 35)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "Slider(value: $value, in: 0...100)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        """
    }
}

// MARK: - UIStepper Demo

public struct UIKitUIStepperDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIStepper"
    public let titleKey = "demo.uistepper.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .stepper(key: "value", titleKey: "param.value", min: 0, max: 20, defaultValue: 4),
        .boolean(key: "enabled", titleKey: "param.enabled", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default"),
        DemoVariant(id: "disabled", titleKey: "variant.disabled", stateOverrides: ["enabled": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        let val = Double(state.int(for: "value", default: 4))
        let enabled = state.bool(for: "enabled", default: true)

        return AnyView(
            UIKitViewHost {
                let stepper = UIStepper()
                stepper.minimumValue = 0
                stepper.maximumValue = 20
                stepper.value = val
                stepper.isEnabled = enabled
                return stepper
            }
            .frame(width: 100, height: 35)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "Stepper(\"Guests: \\(value)\", value: $value, in: 0...20)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 20
        stepper.value = 4
        """
    }
}

// MARK: - UIDatePicker Demo

public struct UIKitUIDatePickerDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIDatePicker"
    public let titleKey = "demo.uidatepicker.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .picker(key: "style", titleKey: "param.style", options: ["compact", "inline", "wheels"], defaultValue: "compact")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "compact", titleKey: "variant.compact", stateOverrides: ["style": AnySendable("compact")]),
        DemoVariant(id: "inline", titleKey: "variant.inline", stateOverrides: ["style": AnySendable("inline")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        let style = state.string(for: "style", default: "compact")

        return AnyView(
            UIKitViewHost {
                let picker = UIDatePicker()
                picker.preferredDatePickerStyle = Self.resolveStyle(style)
                return picker
            }
            .frame(height: style == "inline" ? 300 : 44)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    #if canImport(UIKit)
    private static func resolveStyle(_ s: String) -> UIDatePickerStyle {
        switch s {
        case "inline": return .inline
        case "wheels": return .wheels
        default: return .compact
        }
    }
    #endif

    public func swiftUICode(state: DemoState) -> String {
        "DatePicker(\"Date\", selection: $date)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        """
    }
}

// MARK: - UIPickerView Demo

public struct UIKitUIPickerViewDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIPickerView"
    public let titleKey = "demo.uipickerview.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = []

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewHost {
                let picker = UIPickerView()
                let delegate = MockPickerDelegate()
                picker.dataSource = delegate
                picker.delegate = delegate
                objc_setAssociatedObject(picker, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return picker
            }
            .frame(height: 140)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "Picker(\"Option\", selection: $selected) { ... }.pickerStyle(.wheel)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        """
    }
}

#if canImport(UIKit)
private final class MockPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let items = ["Red", "Green", "Blue", "Yellow", "Purple"]
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { items.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { items[row] }
}
#endif

// MARK: - UITextField Demo

public struct UIKitUITextFieldDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UITextField"
    public let titleKey = "demo.uitextfield.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .text(key: "placeholder", titleKey: "param.placeholder", defaultValue: "Enter text...")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        let placeholder = state.string(for: "placeholder", default: "Enter text...")

        return AnyView(
            UIKitViewHost {
                let tf = UITextField()
                tf.placeholder = placeholder
                tf.borderStyle = .roundedRect
                return tf
            }
            .frame(width: 240, height: 35)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "TextField(\"Enter text...\", text: $text).textFieldStyle(.roundedBorder)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let tf = UITextField()
        tf.placeholder = "Enter text..."
        tf.borderStyle = .roundedRect
        """
    }
}

// MARK: - UITextView Demo

public struct UIKitUITextViewDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UITextView"
    public let titleKey = "demo.uitextview.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = []

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewHost {
                let tv = UITextView()
                tv.text = "UITextView supports rich multiline text editing and selection."
                tv.font = .preferredFont(forTextStyle: .body)
                tv.layer.borderColor = UIColor.separator.cgColor
                tv.layer.borderWidth = 1
                tv.layer.cornerRadius = 8
                return tv
            }
            .frame(width: 260, height: 100)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "TextEditor(text: $text)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let tv = UITextView()
        tv.text = "Hello world"
        tv.font = .preferredFont(forTextStyle: .body)
        """
    }
}

// MARK: - UISegmentedControl Demo

public struct UIKitUISegmentedControlDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UISegmentedControl"
    public let titleKey = "demo.uisegmentedcontrol.title"
    public let familyID = "selection-input"

    public let parameters: [DemoParameter] = [
        .stepper(key: "selected", titleKey: "param.selected_index", min: 0, max: 2, defaultValue: 0)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        let selected = state.int(for: "selected", default: 0)

        return AnyView(
            UIKitViewHost {
                let seg = UISegmentedControl(items: ["First", "Second", "Third"])
                seg.selectedSegmentIndex = selected
                return seg
            }
            .frame(width: 240, height: 35)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "Picker(\"Options\", selection: $selection) { ... }.pickerStyle(.segmented)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let seg = UISegmentedControl(items: ["First", "Second", "Third"])
        seg.selectedSegmentIndex = 0
        seg.addTarget(self, action: #selector(segChanged), for: .valueChanged)
        """
    }
}
