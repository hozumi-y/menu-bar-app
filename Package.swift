// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MenuBarNetworkMonitor",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MenuBarNetworkMonitor", targets: ["MenuBarNetworkMonitor"])
    ],
    targets: [
        .executableTarget(
            name: "MenuBarNetworkMonitor",
            path: "Sources/MenuBarNetworkMonitor",
            exclude: ["Info.plist"]
        )
    ]
)
