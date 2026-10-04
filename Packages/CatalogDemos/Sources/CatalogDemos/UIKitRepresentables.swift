#if canImport(UIKit)
import UIKit
import SwiftUI

public struct UIKitViewHost<V: UIView>: UIViewRepresentable {
    public let makeView: () -> V

    public init(_ make: @escaping () -> V) {
        self.makeView = make
    }

    public func makeUIView(context: Context) -> V {
        makeView()
    }

    public func updateUIView(_ uiView: V, context: Context) {}
}

public struct UIKitViewControllerHost<VC: UIViewController>: UIViewControllerRepresentable {
    public let makeViewController: () -> VC

    public init(_ make: @escaping () -> VC) {
        self.makeViewController = make
    }

    public func makeUIViewController(context: Context) -> VC {
        makeViewController()
    }

    public func updateUIViewController(_ uiViewController: VC, context: Context) {}
}
#endif
