import SwiftUI
import CatalogModel

struct APISignaturesView: View {
    let symbol: CatalogSymbol

    var body: some View {
        List {
            // General Info Section
            Section(header: Text("api.general")) {
                LabeledContent("api.framework", value: symbol.framework.rawValue)
                LabeledContent("api.kind", value: symbol.kind.rawValue)
                if let superclass = symbol.superclass {
                    LabeledContent("api.superclass", value: superclass)
                }
                if let intro = symbol.availability.introduced {
                    LabeledContent("api.introduced", value: "iOS \(intro.description)")
                }
                if symbol.availability.isDeprecated {
                    LabeledContent("api.status", value: "Deprecated")
                }
            }

            // Conformances
            if !symbol.conformances.isEmpty {
                Section(header: Text("api.conformances")) {
                    ForEach(symbol.conformances, id: \.self) { conf in
                        Text(conf)
                            .font(.system(.subheadline, design: .monospaced))
                    }
                }
            }

            // Enum / OptionSet Cases
            if !symbol.enumCases.isEmpty || !symbol.optionSetCases.isEmpty {
                Section(header: Text("api.cases")) {
                    ForEach(symbol.enumCases + symbol.optionSetCases, id: \.self) { c in
                        HStack {
                            Text("case")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(c)
                                .font(.system(.subheadline, design: .monospaced))
                        }
                    }
                }
            }

            // Initializers / Signatures
            if !symbol.signatures.isEmpty {
                Section(header: Text("api.initializers")) {
                    ForEach(symbol.signatures, id: \.declaration) { sig in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(sig.declaration)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundStyle(.primary)

                            if !sig.parameters.isEmpty {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(sig.parameters, id: \.name) { p in
                                        HStack(alignment: .top) {
                                            Text(p.label ?? "_")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                            Text(p.name + ":")
                                                .font(.caption2)
                                                .bold()
                                            Text(p.type)
                                                .font(.caption2)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                }
                                .padding(.leading, 8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            // Members (methods and properties)
            if !symbol.members.isEmpty {
                Section(header: Text("api.members")) {
                    ForEach(symbol.members) { mem in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(mem.kind.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.secondary.opacity(0.12), in: Capsule())
                                Text(mem.name)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .bold()
                            }
                            Text(mem.declaration)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
