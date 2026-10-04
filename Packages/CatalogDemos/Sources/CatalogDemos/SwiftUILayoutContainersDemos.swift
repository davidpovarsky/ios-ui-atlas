import SwiftUI
import CatalogModel

// MARK: - List Demo

public struct SwiftUIListDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.List"
    public let titleKey = "demo.list.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = [
        .picker(key: "style", titleKey: "param.style", options: ["insetGrouped", "plain", "grouped", "sidebar"], defaultValue: "insetGrouped")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "insetGrouped", titleKey: "variant.inset_grouped", stateOverrides: ["style": AnySendable("insetGrouped")]),
        DemoVariant(id: "plain", titleKey: "variant.plain", stateOverrides: ["style": AnySendable("plain")]),
        DemoVariant(id: "sidebar", titleKey: "variant.sidebar", stateOverrides: ["style": AnySendable("sidebar")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let style = state.string(for: "style", default: "insetGrouped")
        let items = [
            ("Display & Brightness", "sun.max.fill", Color.blue),
            ("Accessibility", "figure.roll", Color.blue),
            ("Wallpaper", "paintpalette.fill", Color.cyan),
            ("Siri & Search", "waveform", Color.purple)
        ]

        let list = List {
            Section("Settings") {
                ForEach(items, id: \.0) { item in
                    HStack {
                        Image(systemName: item.1)
                            .foregroundStyle(item.2)
                            .frame(width: 24)
                        Text(item.0)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }

        return AnyView(
            VStack {
                switch style {
                case "plain": list.listStyle(.plain)
                case "grouped": list.listStyle(.grouped)
                case "sidebar": list.listStyle(.sidebar)
                default: list.listStyle(.insetGrouped)
                }
            }
            .frame(height: 240)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let style = state.string(for: "style", default: "insetGrouped")
        return """
        List {
            Section("Settings") {
                ForEach(items, id: \\.id) { item in
                    Label(item.title, systemImage: item.icon)
                }
            }
        }
        .listStyle(.\(style))
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        """
    }
}

// MARK: - Form Demo

public struct SwiftUIFormDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Form"
    public let titleKey = "demo.form.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = [
        .text(key: "username", titleKey: "param.username", defaultValue: "david"),
        .boolean(key: "notifications", titleKey: "param.notifications", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let bindingUsername = Binding<String>(
            get: { state.string(for: "username", default: "david") },
            set: { state.strings["username"] = $0 }
        )
        let bindingNotify = Binding<Bool>(
            get: { state.bool(for: "notifications", default: true) },
            set: { state.booleans["notifications"] = $0 }
        )

        return AnyView(
            Form {
                Section("Account") {
                    TextField("Username", text: bindingUsername)
                }
                Section("Preferences") {
                    Toggle("Push Notifications", isOn: bindingNotify)
                }
            }
            .frame(height: 220)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        Form {
            Section("Account") {
                TextField("Username", text: $username)
            }
            Section("Preferences") {
                Toggle("Push Notifications", isOn: $notifications)
            }
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        // In UIKit, forms are built using UITableView with .insetGrouped style
        // and cell registration with UIListContentConfiguration.
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        """
    }
}

// MARK: - ScrollView Demo

public struct SwiftUIScrollViewDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.ScrollView"
    public let titleKey = "demo.scrollview.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = [
        .picker(key: "axis", titleKey: "param.axis", options: ["vertical", "horizontal"], defaultValue: "horizontal"),
        .boolean(key: "showsIndicators", titleKey: "param.shows_indicators", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "horizontal", titleKey: "variant.horizontal", stateOverrides: ["axis": AnySendable("horizontal")]),
        DemoVariant(id: "vertical", titleKey: "variant.vertical", stateOverrides: ["axis": AnySendable("vertical")])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let axis = state.string(for: "axis", default: "horizontal")
        let indicators = state.bool(for: "showsIndicators", default: true)

        let colors: [Color] = [.blue, .purple, .pink, .orange, .green]

        return AnyView(
            Group {
                if axis == "horizontal" {
                    ScrollView(.horizontal, showsIndicators: indicators) {
                        HStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colors[i].gradient)
                                    .frame(width: 100, height: 100)
                                    .overlay(Text("\(i + 1)").font(.title).bold().foregroundStyle(.white))
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: indicators) {
                        VStack(spacing: 12) {
                            ForEach(0..<5, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colors[i].gradient)
                                    .frame(height: 60)
                                    .overlay(Text("Item \(i + 1)").font(.headline).foregroundStyle(.white))
                            }
                        }
                        .padding()
                    }
                    .frame(height: 180)
                }
            }
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let axis = state.string(for: "axis", default: "horizontal")
        let indicators = state.bool(for: "showsIndicators", default: true)
        return """
        ScrollView(.\(axis), showsIndicators: \(indicators)) {
            // content
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.addSubview(contentView)
        """
    }
}

// MARK: - Grid Demo

public struct SwiftUIGridDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.Grid"
    public let titleKey = "demo.grid.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = [
        .stepper(key: "rows", titleKey: "param.rows", min: 2, max: 4, defaultValue: 2)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let rows = state.int(for: "rows", default: 2)

        return AnyView(
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(0..<rows, id: \.self) { r in
                    GridRow {
                        ForEach(0..<3, id: \.self) { c in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(Double(r + 1) * 0.25))
                                .frame(width: 60, height: 40)
                                .overlay(Text("\(r),\(c)").font(.caption).bold())
                        }
                    }
                }
            }
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            GridRow {
                Text("Cell 1")
                Text("Cell 2")
            }
            GridRow {
                Text("Cell 3")
                Text("Cell 4")
            }
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
        )
        """
    }
}

// MARK: - LazyVGrid Demo

public struct SwiftUILazyVGridDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.LazyVGrid"
    public let titleKey = "demo.lazyvgrid.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = [
        .stepper(key: "columns", titleKey: "param.columns", min: 2, max: 4, defaultValue: 3)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let colCount = state.int(for: "columns", default: 3)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: colCount)

        return AnyView(
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<12, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.indigo.opacity(0.8))
                            .frame(height: 50)
                            .overlay(Text("\(i + 1)").foregroundStyle(.white).bold())
                    }
                }
                .padding()
            }
            .frame(height: 180)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(items) { item in
                    ItemView(item)
                }
            }
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        """
    }
}

// MARK: - LazyHGrid Demo

public struct SwiftUILazyHGridDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.LazyHGrid"
    public let titleKey = "demo.lazyhgrid.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = [
        .stepper(key: "rows", titleKey: "param.rows", min: 2, max: 3, defaultValue: 2)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let rowCount = state.int(for: "rows", default: 2)
        let rows = Array(repeating: GridItem(.fixed(50), spacing: 8), count: rowCount)

        return AnyView(
            ScrollView(.horizontal) {
                LazyHGrid(rows: rows, spacing: 8) {
                    ForEach(0..<10, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.teal.opacity(0.8))
                            .frame(width: 70)
                            .overlay(Text("\(i + 1)").foregroundStyle(.white).bold())
                    }
                }
                .padding()
            }
            .frame(height: 140)
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        let rows = [GridItem(.fixed(50)), GridItem(.fixed(50))]

        ScrollView(.horizontal) {
            LazyHGrid(rows: rows, spacing: 8) {
                ForEach(items) { item in
                    ItemView(item)
                }
            }
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        """
    }
}

// MARK: - Stacks: HStack, VStack, ZStack

public struct SwiftUIHStackDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.HStack"
    public let titleKey = "demo.hstack.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = [
        .slider(key: "spacing", titleKey: "param.spacing", min: 0, max: 30, defaultValue: 12)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let spacing = state.double(for: "spacing", default: 12)

        return AnyView(
            HStack(spacing: CGFloat(spacing)) {
                Circle().fill(.red).frame(width: 40, height: 40)
                Circle().fill(.green).frame(width: 40, height: 40)
                Circle().fill(.blue).frame(width: 40, height: 40)
            }
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let spacing = Int(state.double(for: "spacing", default: 12))
        return """
        HStack(spacing: \(spacing)) {
            Circle().fill(.red)
            Circle().fill(.green)
            Circle().fill(.blue)
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let stack = UIStackView(arrangedSubviews: [v1, v2, v3])
        stack.axis = .horizontal
        stack.spacing = 12
        """
    }
}

public struct SwiftUIVStackDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.VStack"
    public let titleKey = "demo.vstack.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = [
        .slider(key: "spacing", titleKey: "param.spacing", min: 0, max: 30, defaultValue: 12)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let spacing = state.double(for: "spacing", default: 12)

        return AnyView(
            VStack(spacing: CGFloat(spacing)) {
                RoundedRectangle(cornerRadius: 6).fill(.orange).frame(width: 120, height: 25)
                RoundedRectangle(cornerRadius: 6).fill(.purple).frame(width: 120, height: 25)
                RoundedRectangle(cornerRadius: 6).fill(.cyan).frame(width: 120, height: 25)
            }
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        let spacing = Int(state.double(for: "spacing", default: 12))
        return """
        VStack(spacing: \(spacing)) {
            ViewA()
            ViewB()
            ViewC()
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let stack = UIStackView(arrangedSubviews: [v1, v2, v3])
        stack.axis = .vertical
        stack.spacing = 12
        """
    }
}

public struct SwiftUIZStackDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.ZStack"
    public let titleKey = "demo.zstack.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = []
    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.gradient)
                    .frame(width: 140, height: 140)
                Circle()
                    .fill(.white.opacity(0.8))
                    .frame(width: 70, height: 70)
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)
            }
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(.blue)
            Circle().fill(.white)
            Image(systemName: "star.fill")
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        // UIKit arranges layers via view hierarchy:
        parentView.addSubview(bottomView)
        parentView.addSubview(middleView)
        parentView.addSubview(topView)
        """
    }
}

// MARK: - DisclosureGroup Demo

public struct SwiftUIDisclosureGroupDemo: CatalogDemoProvider {
    public let symbolID = "SwiftUI.DisclosureGroup"
    public let titleKey = "demo.disclosuregroup.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = [
        .text(key: "title", titleKey: "param.title", defaultValue: "Advanced Options"),
        .boolean(key: "isExpanded", titleKey: "param.is_expanded", defaultValue: true)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "expanded", titleKey: "variant.expanded", stateOverrides: ["isExpanded": AnySendable(true)]),
        DemoVariant(id: "collapsed", titleKey: "variant.collapsed", stateOverrides: ["isExpanded": AnySendable(false)])
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        let title = state.string(for: "title", default: "Advanced Options")
        let binding = Binding<Bool>(
            get: { state.bool(for: "isExpanded", default: true) },
            set: { state.booleans["isExpanded"] = $0 }
        )

        return AnyView(
            DisclosureGroup(title, isExpanded: binding) {
                VStack(alignment: .leading, spacing: 6) {
                    Toggle("Developer Mode", isOn: .constant(true))
                    Toggle("Verbose Logs", isOn: .constant(false))
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: 280)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        )
    }

    public func swiftUICode(state: DemoState) -> String {
        """
        @State private var isExpanded = true

        DisclosureGroup("Advanced Options", isExpanded: $isExpanded) {
            Toggle("Developer Mode", isOn: $devMode)
            Toggle("Verbose Logs", isOn: $logs)
        }
        """
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        // In UIKit, hierarchical disclosure is supported via UICollectionView list with UICellAccessory.outlineDisclosure()
        """
    }
}
