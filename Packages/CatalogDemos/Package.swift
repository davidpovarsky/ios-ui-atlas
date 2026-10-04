// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CatalogDemos",
    platforms: [.iOS(.v26), .macOS(.v15)],
    products: [
        .library(name: "CatalogDemos", targets: ["CatalogDemos"]),
    ],
    dependencies: [
        .package(path: "../CatalogModel"),
    ],
    targets: [
        .target(
            name: "CatalogDemos",
            dependencies: [
                .product(name: "CatalogModel", package: "CatalogModel"),
            ]
        ),
        .testTarget(
            name: "CatalogDemosTests",
            dependencies: ["CatalogDemos", .product(name: "CatalogModel", package: "CatalogModel")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
