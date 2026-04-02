// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FellohPaymentSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FellohPaymentSDK",
            targets: ["FellohPaymentSDK"]
        )
    ],
    targets: [
        .target(
            name: "FellohPaymentSDK",
            path: "Sources/FellohPaymentSDK"
        ),
        .testTarget(
            name: "FellohPaymentSDKTests",
            dependencies: ["FellohPaymentSDK"],
            path: "Tests/FellohPaymentSDKTests"
        )
    ]
)
