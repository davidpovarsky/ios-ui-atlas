#if canImport(UIKit)
import UIKit
import SwiftUI

public struct UIKitViewHost<V: UIView>: UIViewRepresentable {
    public let makeView: (Context) -> V
    public let updateView: (V, Context) -> Void

    public init(
        make: @escaping (Context) -> V,
        update: @escaping (V, Context) -> Void = { _, _ in }
    ) {
        self.makeView = make
        self.updateView = update
    }

    public func makeUIView(context: Context) -> V {
        makeView(context)
    }

    public func updateUIView(_ uiView: V, context: Context) {
        updateView(uiView, context)
    }
}

public struct UIKitViewControllerHost<VC: UIViewController>: UIViewControllerRepresentable {
    public let makeViewController: (Context) -> VC
    public let updateViewController: (VC, Context) -> Void

    public init(
        make: @escaping (Context) -> VC,
        update: @escaping (VC, Context) -> Void = { _, _ in }
    ) {
        self.makeViewController = make
        self.updateViewController = update
    }

    public func makeUIViewController(context: Context) -> VC {
        makeViewController(context)
    }

    public func updateUIViewController(_ uiViewController: VC, context: Context) {
        updateViewController(uiViewController, context)
    }
}
#endif
