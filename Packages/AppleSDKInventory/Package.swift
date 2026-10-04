// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AppleSDKInventory",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "AppleSDKInventoryCore", targets: ["AppleSDKInventoryCore"]),
        .executable(name: "sdk-inventory", targets: ["SDKInventoryCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "603.0.2"),
        .package(path: "../CatalogModel"),
    ],
    targets: [
        .target(
            name: "AppleSDKInventoryCore",
            dependencies: [
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "CatalogModel", package: "CatalogModel"),
            ]
        ),
        .executableTarget(
            name: "SDKInventoryCLI",
            dependencies: [
                "AppleSDKInventoryCore",
                .product(name: "CatalogModel", package: "CatalogModel"),
            ]
        ),
        .testTarget(
            name: "AppleSDKInventoryTests",
            dependencies: [
                "AppleSDKInventoryCore",
                .product(name: "CatalogModel", package: "CatalogModel"),
            ],
            resources: [.copy("Fixtures")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
