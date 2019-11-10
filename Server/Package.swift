// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GMTC-Swift-on-Pi",
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.10.0"),
        .package(url: "https://github.com/uraimo/SwiftyGPIO.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Server",
            dependencies: ["NIO", "NIOFoundationCompat", "SwiftyGPIO"]),
        .target(
            name: "LED",
            dependencies: ["SwiftyGPIO"]
        ),
        .target(
            name: "Button",
            dependencies: ["SwiftyGPIO"]
        ),
        .target(
            name: "RGBLED",
            dependencies: ["SwiftyGPIO"]
        ),
        .target(
            name: "UpdateLED",
            dependencies: ["SwiftyGPIO", "RGBLED"]
        )
    ]
)
