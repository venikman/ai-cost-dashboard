// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AICostDashboard",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        // Core library — all models, services, views, utilities
        .target(
            name: "AICostDashboard",
            path: "Sources/AICostDashboard"
        ),
        // Thin executable — just the @main entry point
        .executableTarget(
            name: "AICostDashboardApp",
            dependencies: ["AICostDashboard"],
            path: "Sources/AICostDashboardApp"
        ),
        // Tests
        .testTarget(
            name: "AICostDashboardTests",
            dependencies: ["AICostDashboard"],
            path: "Tests/AICostDashboardTests"
        ),
    ]
)
