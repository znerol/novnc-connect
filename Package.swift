// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "novnc-connect",
    products: [
        .executable(
            name: "novnc-connect",
            targets: ["novnc-connect"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/znerol/socketwebify", from: "1.0.1"),
    ],
    targets: [
        .target(name: "novnc-connect", dependencies: [
            .product(name: "WebTunnel", package: "socketwebify"),
        ]),
    ]
)
