import SwiftUI
import CatalogModel

struct SettingsView: View {
    @ObservedObject var store = CatalogStore.shared
    @ObservedObject var favorites = FavoritesManager.shared

    var body: some View {
        List {
            Section(header: Text("settings.sdk_environment")) {
                if let sdk = store.manifest?.sdk {
                    LabeledContent("settings.xcode", value: sdk.xcodeVersion)
                    LabeledContent("settings.xcode_build", value: sdk.xcodeBuild)
                    LabeledContent("settings.sdk_version", value: "\(sdk.sdkName) \(sdk.sdkVersion)")
                    LabeledContent("settings.target_triple", value: sdk.targetTriple)
                } else {
                    LabeledContent("settings.xcode", value: "Xcode 27.0")
                    LabeledContent("settings.sdk_version", value: "iOS 27.0")
                }
            }

            Section(header: Text("settings.developer_options")) {
                Toggle("settings.show_internal", isOn: $store.showInternalSymbols)
            }

            Section(header: Text("settings.library_data")) {
                HStack {
                    Text("settings.clear_recents")
                    Spacer()
                    Button("settings.clear", role: .destructive) {
                        favorites.clearRecents()
                    }
                }
            }

            Section(header: Text("settings.about")) {
                LabeledContent("settings.version", value: "1.0.0")
                LabeledContent("settings.license", value: "MIT")
                Text("settings.disclaimer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("sidebar.settings")
    }
}
