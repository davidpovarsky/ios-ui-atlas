// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CatalogModel",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CatalogModel", targets: ["CatalogModel"]),
    ],
    targets: [
        .target(name: "CatalogModel"),
        .testTarget(name: "CatalogModelTests", dependencies: ["CatalogModel"]),
    ],
    swiftLanguageModes: [.v6]
)
