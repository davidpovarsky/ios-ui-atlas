# iOS UI Atlas

[![Validate](https://github.com/davidpovarsky/ios-ui-atlas/actions/workflows/validate.yml/badge.svg)](https://github.com/davidpovarsky/ios-ui-atlas/actions/workflows/validate.yml)
[![Build iOS Unsigned IPA](https://github.com/davidpovarsky/ios-ui-atlas/actions/workflows/build-unsigned-ipa.yml/badge.svg)](https://github.com/davidpovarsky/ios-ui-atlas/actions/workflows/build-unsigned-ipa.yml)

A high-performance, native developer tool, interactive catalog, and authoritative API reference for iOS **SwiftUI** and **UIKit** components. Built for iPhone and iPad in native Swift and SwiftUI, with complete bilingual English and Hebrew support.

---

## Key Features

- **Live Native Previews**: Curated interactive demos across all major HIG component families with realistic layout constraints and real native modals (`sheet` with detents, `popover`, `alert`, `confirmationDialog`, `fullScreenCover`).
- **Complete Framework Parity**: SwiftUI and UIKit representations side-by-side with explicit cross-framework conceptual relationships (e.g. `Button` ↔ `UIButton`, `sheet` ↔ `UISheetPresentationController`, `searchable` ↔ `UISearchController`).
- **Dynamic Parameter Inspector**: Interactive native `Form` playground inspector to tune titles, styles, states, sizes, colors, and controls in real time.
- **Copyable Code Snippets**: Clean, idiomatic, standalone SwiftUI and UIKit code snippets ready to paste into production projects (always rendered in code fonts and left-to-right).
- **Official Documentation & HIG Links**: Direct, version-safe links to Apple Developer Documentation and Apple Human Interface Guidelines.
- **Automated SDK Inventory Generator**: Extensible compiler toolchain that parses SwiftUI `.swiftinterface` files via SwiftSyntax and UIKit via `swift-symbolgraph-extract`.
- **Fast Ranked Search**: In-memory, zero-dependency search index matching exact symbol names, aliases, prefix matches, member properties, and semantic tags.
- **Adaptive iPhone & iPad Layout**: 3-column `NavigationSplitView` on iPad (Sidebar, Symbols, Detail) that fluidly adapts to a standard stack navigation on iPhone.
- **Bilingual Localization (English & Hebrew)**: Native localization using `Localizable.xcstrings` with proper Right-to-Left (RTL) layout mirroring while preserving LTR code readability.

---

## Architecture

The project is structured into clean, modular layers separating authoritative SDK facts from human-curated developer experience:

```
ios-ui-atlas/
├── App/
│   └── iOSUIAtlas/            # Native SwiftUI application shell & views
│       ├── Views/              # Sidebar, Home, List, Detail, Inspector, Code
│       ├── Model/              # App state, persistence, favorites & recents
│       └── Resources/          # Localizable.xcstrings (en, he) & Assets
├── Packages/
│   ├── CatalogModel/          # Core framework-neutral schema & fast search index
│   ├── CatalogDemos/          # 71 curated interactive live demos & parameter models
│   └── AppleSDKInventory/     # CLI & parsers for .swiftinterface & symbol graphs
├── Metadata/                  # Human-curated metadata (families, relationships, aliases)
├── Tests/
│   ├── iOSUIAtlasTests/       # App logic, store, favorites, and localization tests
│   └── iOSUIAtlasUITests/     # UI smoke tests for launch, search, detail, and RTL
└── .github/workflows/         # Automated validation and unsigned IPA CI pipelines
```

### Generated vs. Curated Layer

1. **Authoritative Generated Layer** (`AppleSDKInventory`):
   - Parsed directly from the active Xcode SDK (`SwiftUI.swiftinterface`, `SwiftUICore.swiftinterface`, and `UIKit.symbols.json`).
   - Extracts symbol names, kinds, availability, full type signatures, initializers, modifiers, and protocol conformances.
   - Outputs reproducible, deterministic JSON catalogs with SHA-256 integrity hashes.

2. **Curated Experience Layer** (`Metadata/` & `CatalogDemos`):
   - HIG family classification and navigation hierarchy.
   - Conceptual SwiftUI ↔ UIKit relationship mappings.
   - Search aliases and developer keywords (e.g., searching "pushbutton" finds `Button` and `UIButton`).
   - Curated live demo providers conforming to `CatalogDemoProvider`.

---

## Component Families

The catalog organizes components into 12 distinct families:

1. **Controls** (`family.controls`): Buttons, Toggles, Sliders, Steppers, Pickers, TextFields, DatePickers, Segmented Controls.
2. **Indicators** (`family.indicators`): ProgressViews, Gauges, Activity Indicators, Status Labels.
3. **Menus & Actions** (`family.menus_actions`): Menus, ControlGroups, Context Menus, ShareLinks, UIAction palettes.
4. **Layout & Containers** (`family.layout_containers`): Lists, Forms, ScrollViews, Grids, Stacks, DisclosureGroups.
5. **Navigation** (`family.navigation`): NavigationStacks, SplitViews, Toolbars, TabViews, Search Bars.
6. **Presentation** (`family.presentation`): Sheets with detents, Popovers, Alerts, Dialogs, Document pickers, Font pickers.
7. **Views & Drawing** (`family.views`): Labels, Images, Shapes, Canvases, Tables, Collection Views.
8. **Feedback & Status** (`family.feedback`): Empty states, Content Unavailable views, sensory feedback.
9. **Developer Reference** (`family.developer_reference`): Raw public API signatures and protocol conformances.
10. **Modifiers** (`family.modifiers`): View styling, layout, animation, and interaction modifiers.
11. **Protocols & Types** (`family.protocols_types`): Fundamental protocol contracts and conformances.
12. **Environment & State** (`family.environment_state`): Environment keys, Property Wrappers, Dynamic properties.

---

## Regenerating SDK Inventory

The SDK inventory can be regenerated deterministically on macOS using Xcode 16/27 command-line tools:

```bash
# 1. Extract UIKit symbol graph
SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
mkdir -p Metadata/Generated/UIKitSymbols
xcrun swift-symbolgraph-extract \
  -module-name UIKit \
  -target arm64-apple-ios17.0 \
  -sdk "$SDK_PATH" \
  -output-dir Metadata/Generated/UIKitSymbols

# 2. Run the inventory generator CLI
swift run --package-path Packages/AppleSDKInventory sdk-inventory \
  --swiftui-core "$SDK_PATH/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64-apple-ios.swiftinterface" \
  --swiftui "$SDK_PATH/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/arm64-apple-ios.swiftinterface" \
  --uikit-symbols Metadata/Generated/UIKitSymbols \
  --metadata Metadata \
  --output Metadata/Generated/catalog-runtime.json
```

Use the `--check` flag in CI to verify that the generated inventory remains deterministic without uncommitted drift.

---

## Building Locally

### Prerequisites

- macOS 14.0+ (macOS 15/27 recommended)
- Xcode 16.0+ or Xcode 27.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Project Generation & Building

1. Clone the repository:
   ```bash
   git clone https://github.com/davidpovarsky/ios-ui-atlas.git
   cd ios-ui-atlas
   ```

2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open in Xcode:
   ```bash
   open iOSUIAtlas.xcodeproj
   ```

4. Or run tests from the command line:
   ```bash
   xcodebuild test \
     -project iOSUIAtlas.xcodeproj \
     -scheme iOSUIAtlas \
     -destination 'platform=iOS Simulator,name=iPhone 16' \
     CODE_SIGNING_ALLOWED=NO
   ```

---

## Continuous Integration & Unsigned IPA

The repository runs two primary GitHub Actions workflows:

1. **`validate.yml`**: Runs on pull requests and pushes to `main`. Executes package tests, regenerates project files, and runs unit and UI smoke tests on iPhone and iPad simulators.
2. **`build-unsigned-ipa.yml`**: Builds the app for physical iOS devices (`generic/platform=iOS`) with code signing disabled (`CODE_SIGNING_ALLOWED=NO`), bundles it into standard `Payload/iOS UI Atlas.app`, and packages `iOS-UI-Atlas-unsigned.ipa`.

### Artifacts Produced

- **`iOS-UI-Atlas-unsigned-ipa`**: Contains `iOS-UI-Atlas-unsigned.ipa`, ready for testing, sideloading, or enterprise distribution via TrollStore, AltStore, or Apple Configurator.
- **`iOS-UI-Atlas-build-logs`**: Comprehensive build logs and timing summaries.
- **`SDK-inventory`**: Extracted SDK symbol catalogs and metadata.

---

## Contributing

To add a new live demo:

1. Create a new demo provider implementing `CatalogDemoProvider`:
   ```swift
   import SwiftUI
   import CatalogModel
   import CatalogDemos

   public struct MyNewDemoProvider: CatalogDemoProvider {
       public let id = "my-new-demo"
       public let symbolID = "SwiftUI.MyComponent"
       public let title = "My Component Demo"
       public let summary = "Demonstrates interactive options for MyComponent."
       public let family = "controls"
       public let parameters: [DemoParameter] = [ ... ]

       public func makePreviewView(state: DemoState) -> AnyView {
           AnyView(MyComponentPreview(state: state))
       }

       public func generateSwiftUICode(state: DemoState) -> String { ... }
       public func generateUIKitCode(state: DemoState) -> String { ... }
   }
   ```
2. Register the provider in `CatalogDemoRegistry.swift`.
3. Add any custom search aliases or relationship links in `Metadata/aliases.json` or `Metadata/relationships.json`.

---

## Disclaimer

This is an independent open-source developer tool. It is not affiliated with, sponsored by, or endorsed by Apple Inc. Apple, SwiftUI, UIKit, iOS, iPadOS, and Xcode are trademarks of Apple Inc., registered in the U.S. and other countries.

---

## License

MIT License. See [LICENSE](LICENSE) for details.
