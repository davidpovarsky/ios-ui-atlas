import SwiftUI

extension CatalogDemoRegistry {
    func registerBuiltinDemos() {
        // SwiftUI Controls
        register(SwiftUIButtonDemo())
        register(SwiftUIToggleDemo())
        register(SwiftUISliderDemo())
        register(SwiftUIStepperDemo())
        register(SwiftUIPickerDemo())
        register(SwiftUIDatePickerDemo())
        register(SwiftUIColorPickerDemo())
        register(SwiftUITextFieldDemo())
        register(SwiftUISecureFieldDemo())
        register(SwiftUITextEditorDemo())

        // SwiftUI Indicators & Content
        register(SwiftUIProgressViewDemo())
        register(SwiftUIGaugeDemo())
        register(SwiftUILabelDemo())
        register(SwiftUILabeledContentDemo())
        register(SwiftUIContentUnavailableViewDemo())
        register(SwiftUIAsyncImageDemo())

        // SwiftUI Menus & Actions
        register(SwiftUIMenuDemo())
        register(SwiftUIControlGroupDemo())
        register(SwiftUIContextMenuDemo())
        register(SwiftUIShareLinkDemo())

        // SwiftUI Layout & Organization
        register(SwiftUIListDemo())
        register(SwiftUIFormDemo())
        register(SwiftUIScrollViewDemo())
        register(SwiftUIGridDemo())
        register(SwiftUILazyVGridDemo())
        register(SwiftUILazyHGridDemo())
        register(SwiftUIHStackDemo())
        register(SwiftUIVStackDemo())
        register(SwiftUIZStackDemo())
        register(SwiftUIDisclosureGroupDemo())

        // SwiftUI Navigation & Search
        register(SwiftUINavigationStackDemo())
        register(SwiftUINavigationSplitViewDemo())
        register(SwiftUINavigationLinkDemo())
        register(SwiftUITabViewDemo())
        register(SwiftUIToolbarDemo())
        register(SwiftUISearchableDemo())

        // SwiftUI Presentation
        register(SwiftUISheetDemo())
        register(SwiftUIFullScreenCoverDemo())
        register(SwiftUIPopoverDemo())
        register(SwiftUIAlertDemo())
        register(SwiftUIConfirmationDialogDemo())
        register(SwiftUIInspectorDemo())

        // UIKit Controls
        register(UIKitUIButtonDemo())
        register(UIKitUISwitchDemo())
        register(UIKitUISliderDemo())
        register(UIKitUIStepperDemo())
        register(UIKitUIDatePickerDemo())
        register(UIKitUIPickerViewDemo())
        register(UIKitUITextFieldDemo())
        register(UIKitUITextViewDemo())
        register(UIKitUISegmentedControlDemo())

        // UIKit Views
        register(UIKitUILabelDemo())
        register(UIKitUIImageViewDemo())
        register(UIKitUIProgressViewDemo())
        register(UIKitUITableViewDemo())
        register(UIKitUICollectionViewDemo())

        // UIKit Presentation
        register(UIKitUIAlertControllerDemo())
        register(UIKitUISheetPresentationControllerDemo())
        register(UIKitUIPopoverPresentationControllerDemo())
        register(UIKitUIMenuDemo())
        register(UIKitUIActionDemo())
        register(UIKitUIContextMenuInteractionDemo())
        register(UIKitUIActivityViewControllerDemo())
        register(UIKitUIDocumentPickerViewControllerDemo())
        register(UIKitUIColorPickerViewControllerDemo())
        register(UIKitUIFontPickerViewControllerDemo())

        // UIKit Navigation
        register(UIKitUISearchBarDemo())
        register(UIKitUISearchControllerDemo())
        register(UIKitUINavigationControllerDemo())
        register(UIKitUITabBarControllerDemo())
        register(UIKitUISplitViewControllerDemo())
    }
}
