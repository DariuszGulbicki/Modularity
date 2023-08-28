// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Modularity",
    products: [
        .library(
            name: "Modules",
            targets: ["Modules"]),
        .library(
            name: "PythonModules",
            targets: ["PythonModules"]),
        .library(
            name: "JavascriptModules",
            targets: ["JavascriptModules"]),
        .library(
            name: "Modularity",
            targets: ["Modules", "PythonModules", "JavascriptModules"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jectivex/JXKit.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/pvieito/PythonKit.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Modules",
            dependencies: [],
            path: "Sources/Modules"),
        .target(
            name: "PythonModules",
            dependencies: [.product(name: "PythonKit", package: "PythonKit")],
            path: "Sources/PythonModules"),
        .target(
            name: "JavascriptModules",
            dependencies: [.product(name: "JXKit", package: "JXKit")],
            path: "Sources/JavascriptModules"),
        .testTarget(
            name: "ModularityTests",
            dependencies: ["Modules"]),
    ]
)
