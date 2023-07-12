// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Modularity",
    products: [
        .library(
            name: "Modularity",
            targets: ["Modularity"]),
    ],
    dependencies: [
        // SwifterSwift
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "Modularity",
            dependencies: []),
        .testTarget(
            name: "ModularityTests",
            dependencies: ["Modularity"]),
    ]
)
