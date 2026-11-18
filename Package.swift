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
        .package(url: "https://github.com/JohnSundell/ShellOut", from: "2.3.0"),
        .package(url: "https://github.com/tuist/XcodeProj", from: "9.17.8"),
        .package(url: "https://github.com/luoxiu/Chalk", exact: "0.2.1"),
        .package(url: "https://github.com/kylef/Commander", from: "0.9.2"),
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
            exclude: ["Prototype.swifttemplate"]
        ),
        .target(
            name: "Shared",
            path: "./Sources/Shared"
        ),
        // Example and tests
        .target(
            name: "Mocky_Example_macOS",
            path: "./SwiftyMocky-Example/Shared",
            exclude: ["Swift5.5"] // TODO: remove when macOS 12 released
        ),
        .testTarget(
            name: "SwiftyMockyTests",
            dependencies: ["Mocky_Example_macOS", "SwiftyMocky"],
            path: "./Tests/SwiftyMockyTests",
            exclude: ["Shared/Swift5.5"] // TODO: remove when macOS 12 released
        ),
        .testTarget(
            name: "RuntimeLibaryTests",
            dependencies: ["SwiftyMocky"]
        ),
        // CLI Executable
        .executableTarget(
            name: "SwiftyMockyCLI",
            dependencies: [
                .product(name: "Commander", package: "Commander"),
                "SwiftyMockyCLICore",
            ],
            path: "./Sources/CLI/App"
        ),
        .target(
            name: "SwiftyMockyCLICore",
            dependencies: [
                .product(name: "Commander", package: "Commander"),
                .product(name: "ShellOut", package: "ShellOut"),
                .product(name: "Chalk", package: "Chalk"),
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
