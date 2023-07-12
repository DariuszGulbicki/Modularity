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
