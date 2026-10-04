import SwiftUI
import CatalogModel
#if canImport(UIKit)
import UIKit
#endif

// MARK: - UILabel Demo

public struct UIKitUILabelDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UILabel"
    public let titleKey = "demo.uilabel.title"
    public let familyID = "content"

    public let parameters: [DemoParameter] = [
        .text(key: "text", titleKey: "param.text", defaultValue: "UIKit UILabel with Dynamic Type"),
        .picker(key: "alignment", titleKey: "param.alignment", options: ["natural", "center", "right"], defaultValue: "center")
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        let text = state.string(for: "text", default: "UIKit UILabel with Dynamic Type")
        let alignStr = state.string(for: "alignment", default: "center")

        return AnyView(
            UIKitViewHost {
                let label = UILabel()
                label.text = text
                label.font = .preferredFont(forTextStyle: .headline)
                label.textAlignment = alignStr == "center" ? .center : (alignStr == "right" ? .right : .natural)
                label.numberOfLines = 0
                return label
            }
            .frame(maxWidth: 260)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "Text(\"UIKit UILabel with Dynamic Type\").font(.headline)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let label = UILabel()
        label.text = "UIKit UILabel with Dynamic Type"
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        """
    }
}

// MARK: - UIImageView Demo

public struct UIKitUIImageViewDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIImageView"
    public let titleKey = "demo.uiimageview.title"
    public let familyID = "content"

    public let parameters: [DemoParameter] = []

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewHost {
                let iv = UIImageView(image: UIImage(systemName: "photo.stack.fill"))
                iv.contentMode = .scaleAspectFit
                iv.tintColor = .systemBlue
                return iv
            }
            .frame(width: 80, height: 80)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "Image(systemName: \"photo.stack.fill\").resizable().scaledToFit()"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let imageView = UIImageView(image: UIImage(systemName: "photo.stack.fill"))
        imageView.contentMode = .scaleAspectFit
        """
    }
}

// MARK: - UIProgressView Demo

public struct UIKitUIProgressViewDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UIProgressView"
    public let titleKey = "demo.uiprogressview.title"
    public let familyID = "status"

    public let parameters: [DemoParameter] = [
        .slider(key: "progress", titleKey: "param.progress", min: 0.0, max: 1.0, defaultValue: 0.6)
    ]

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        let p = Float(state.double(for: "progress", default: 0.6))

        return AnyView(
            UIKitViewHost {
                let pv = UIProgressView(progressViewStyle: .default)
                pv.progress = p
                return pv
            }
            .frame(width: 200, height: 20)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "ProgressView(value: 0.6)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progress = 0.6
        """
    }
}

// MARK: - UITableView Demo

public struct UIKitUITableViewDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UITableView"
    public let titleKey = "demo.uitableview.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = []

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewHost {
                let tv = UITableView(frame: .zero, style: .insetGrouped)
                let dataSource = MockTableDataSource()
                tv.dataSource = dataSource
                objc_setAssociatedObject(tv, "ds", dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return tv
            }
            .frame(height: 180)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "List { ... }.listStyle(.insetGrouped)"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        """
    }
}

#if canImport(UIKit)
private final class MockTableDataSource: NSObject, UITableViewDataSource {
    let cells = ["Cellular", "Wi-Fi", "Bluetooth"]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { cells.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var config = cell.defaultContentConfiguration()
        config.text = cells[indexPath.row]
        cell.contentConfiguration = config
        return cell
    }
}
#endif

// MARK: - UICollectionView Demo

public struct UIKitUICollectionViewDemo: CatalogDemoProvider {
    public let symbolID = "UIKit.UICollectionView"
    public let titleKey = "demo.uicollectionview.title"
    public let familyID = "layout-organization"

    public let parameters: [DemoParameter] = []

    public let variants: [DemoVariant] = [
        DemoVariant(id: "default", titleKey: "variant.default")
    ]

    public init() {}

    public func makePreview(state: DemoState) -> AnyView {
        #if canImport(UIKit)
        return AnyView(
            UIKitViewHost {
                let layout = UICollectionViewFlowLayout()
                layout.itemSize = CGSize(width: 44, height: 44)
                layout.scrollDirection = .horizontal
                let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
                cv.backgroundColor = .clear
                let ds = MockCollectionDataSource()
                cv.dataSource = ds
                cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
                objc_setAssociatedObject(cv, "ds", ds, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return cv
            }
            .frame(height: 60)
        )
        #else
        return AnyView(Text("Requires UIKit"))
        #endif
    }

    public func swiftUICode(state: DemoState) -> String {
        "ScrollView(.horizontal) { LazyHStack { ... } }"
    }

    public func uiKitCode(state: DemoState) -> String? {
        """
        let layout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        """
    }
}

#if canImport(UIKit)
private final class MockCollectionDataSource: NSObject, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 10 }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemBlue
        cell.layer.cornerRadius = 8
        return cell
    }
}
#endif
