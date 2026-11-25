// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftymocky",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        // XCTest Runtime libraries
        .library(name: "SwiftyMocky", targets: ["SwiftyMocky"]),
        .library(name: "SwiftyPrototype", targets: ["SwiftyPrototype"]),
        // CLI Executable
        .executable(name: "swiftymocky", targets: ["SwiftyMockyCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/XcodeProj", from: "9.17.8"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.2"),
        .package(url: "https://github.com/kylef/PathKit", from: "1.0.1"),
        .package(url: "https://github.com/jpsim/Yams", from: "6.2.2"),
    ],
    targets: [
        // XCTest Runtime libraries
        .target(
            name: "SwiftyMocky",
            path: "./Sources/SwiftyMocky",
            exclude: ["Mock.swifttemplate"]
        ),
        .target(
            name: "SwiftyPrototype",
            path: "./Sources/SwiftyPrototype",
            exclude: ["Prototype.swifttemplate"],
            swiftSettings: [
                // Shared sources use this to skip XCTest-based assertion and failure handling.
                .define("SWIFTY_PROTOTYPE"),
            ]
        ),
        // Example and tests
        .target(
            name: "Mocky_Example_macOS",
            path: "./SwiftyMocky-Example/Shared"
        ),
        .testTarget(
            name: "SwiftyMockyTests",
            dependencies: ["Mocky_Example_macOS", "SwiftyMocky"],
            path: "./Tests/SwiftyMockyTests"
        ),
        .testTarget(
            name: "RuntimeLibraryTests",
            dependencies: ["SwiftyMocky"]
        ),
        // CLI Executable
        .executableTarget(
            name: "SwiftyMockyCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SwiftyMockyCLICore",
            ],
            path: "./Sources/CLI/App"
        ),
        .target(
            name: "SwiftyMockyCLICore",
            dependencies: [
                .product(name: "XcodeProj", package: "XcodeProj"),
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "Yams", package: "Yams"),
            ],
            path: "./Sources/CLI/Core"
        ),
        .testTarget(
           name: "SwiftyMockyCLICoreTests",
           dependencies: [
               "SwiftyMockyCLICore",
               "SwiftyMocky",
               .product(name: "PathKit", package: "PathKit"),
           ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

// Require `any` for existential types. Generated mocks are compiled with it too,
// so templates emitting a bare protocol type are caught by our own build.
for target in package.targets {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .enableUpcomingFeature("ExistentialAny"),
    ]
}
