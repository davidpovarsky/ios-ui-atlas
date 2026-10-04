import SwiftUI
import CatalogDemos

struct PlaygroundInspectorView: View {
    let parameters: [DemoParameter]
    @ObservedObject var state: DemoState

    var body: some View {
        Form {
            Section(header: Text("inspector.parameters")) {
                ForEach(parameters) { param in
                    parameterControl(for: param)
                }
            }
        }
    }

    @ViewBuilder
    private func parameterControl(for param: DemoParameter) -> some View {
        switch param {
        case .boolean(let key, let titleKey, let defaultValue):
            let binding = Binding<Bool>(
                get: { state.bool(for: key, default: defaultValue) },
                set: { state.booleans[key] = $0 }
            )
            Toggle(LocalizedStringKey(titleKey), isOn: binding)

        case .picker(let key, let titleKey, let options, let defaultValue):
            let binding = Binding<String>(
                get: { state.string(for: key, default: defaultValue) },
                set: { state.strings[key] = $0 }
            )
            Picker(LocalizedStringKey(titleKey), selection: binding) {
                ForEach(options, id: \.self) { opt in
                    Text(opt).tag(opt)
                }
            }

        case .stepper(let key, let titleKey, let min, let max, let defaultValue):
            let binding = Binding<Int>(
                get: { state.int(for: key, default: defaultValue) },
                set: { state.ints[key] = $0 }
            )
            Stepper("\(NSLocalizedString(titleKey, comment: "")): \(binding.wrappedValue)", value: binding, in: min...max)

        case .slider(let key, let titleKey, let min, let max, let defaultValue):
            let binding = Binding<Double>(
                get: { state.double(for: key, default: defaultValue) },
                set: { state.doubles[key] = $0 }
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(LocalizedStringKey(titleKey))
                    Spacer()
                    Text(String(format: "%.1f", binding.wrappedValue))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Slider(value: binding, in: min...max)
            }

        case .text(let key, let titleKey, let defaultValue):
            let binding = Binding<String>(
                get: { state.string(for: key, default: defaultValue) },
                set: { state.strings[key] = $0 }
            )
            TextField(LocalizedStringKey(titleKey), text: binding)
        }
    }
}
