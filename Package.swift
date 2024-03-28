// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scheduling",
    platforms: [.macOS(.v10_13), .iOS(.v12), .tvOS(.v12), .watchOS(.v4)],
    products: [
        .library(
            name: "Scheduling",
            targets: ["Scheduling"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/aetherealtech/swift-assertions", branch: "master"),
        .package(url: "https://github.com/aetherealtech/swift-core-extensions", branch: "master"),
        .package(url: "https://github.com/aetherealtech/swift-synchronization", branch: "master"),
    ],
    targets: [
        .target(
            name: "Scheduling",
            dependencies: [
                .product(name: "Synchronization", package: "swift-synchronization"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "SchedulingTests",
            dependencies: [
                "Scheduling",
                .product(name: "Assertions", package: "swift-assertions"),
                .product(name: "AsyncExtensions", package: "swift-core-extensions"),
                .product(name: "Synchronization", package: "swift-synchronization"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
    ]
)

extension SwiftSetting {
    enum ConcurrencyChecking: String {
        case complete
        case minimal
        case targeted
    }
    
    static func concurrencyChecking(_ setting: ConcurrencyChecking = .minimal) -> Self {
        unsafeFlags([
            "-Xfrontend", "-strict-concurrency=\(setting)",
            "-Xfrontend", "-warn-concurrency",
            "-Xfrontend", "-enable-actor-data-race-checks",
        ])
    }
}
