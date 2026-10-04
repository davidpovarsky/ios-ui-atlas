import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct CodeSnippetView: View {
    let swiftUICode: String
    let uiKitCode: String?
    @State private var selectedTab = 0
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with tab selector and Copy button
            HStack {
                if uiKitCode != nil {
                    Picker("Framework", selection: $selectedTab) {
                        Text("SwiftUI").tag(0)
                        Text("UIKit").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 220)
                }

                Spacer()

                Button(action: copyCode) {
                    Label(copied ? "code.copied" : "code.copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.12), in: Capsule())
                }
                .accessibilityIdentifier("code.copy")
            }

            // Code container — always LTR
            ScrollView([.horizontal, .vertical]) {
                Text(selectedTab == 0 ? swiftUICode : (uiKitCode ?? ""))
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .environment(\.layoutDirection, .leftToRight)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
        }
        .padding()
    }

    private func copyCode() {
        let textToCopy = selectedTab == 0 ? swiftUICode : (uiKitCode ?? "")
        #if canImport(UIKit)
        UIPasteboard.general.string = textToCopy
        #endif
        copied = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            copied = false
        }
    }
}
