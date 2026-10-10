// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TonRateTracker",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "TonRateCore",
            targets: ["TonRateCore"]
        ),
        .executable(
            name: "TonRateTracker",
            targets: ["TonRateTrackerApp"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TonRateCore",
            dependencies: [],
            path: "Sources/TonRateCore"
        ),
        .executableTarget(
            name: "TonRateTrackerApp",
            dependencies: ["TonRateCore"],
            path: "Sources/TonRateTrackerApp"
        ),
        .testTarget(
            name: "TonRateCoreTests",
            dependencies: ["TonRateCore"],
            path: "Tests/TonRateCoreTests"
        ),
    ]
)
