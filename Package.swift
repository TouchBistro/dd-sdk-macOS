// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "Datadog-macOS",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Datadog-macOS",
            targets: ["Datadog-macOS"]
        ),
        .library(
            name: "DatadogObjc-macOS",
            targets: ["DatadogObjc-macOS"]
        ),
        .library(
            name: "DatadogDynamic-macOS",
            type: .dynamic,
            targets: ["Datadog-macOS"]
        ),
        .library(
            name: "DatadogDynamicObjc-macOS",
            type: .dynamic,
            targets: ["DatadogObjc-macOS"]
        ),
        .library( // TODO: RUMM-2387 Consider removing explicit linkage variants
            name: "DatadogStatic-macOS",
            type: .static,
            targets: ["Datadog-macOS"]
        ),
        .library( // TODO: RUMM-2387 Consider removing explicit linkage variants
            name: "DatadogStaticObjc-macOS",
            type: .static,
            targets: ["DatadogObjc-macOS"]
        ),
        .library(
            name: "DatadogCrashReporting-macOS",
            targets: ["DatadogCrashReporting-macOS"]
        ),
    ],
    dependencies: [
        .package(name: "PLCrashReporter", url: "https://github.com/microsoft/plcrashreporter.git", from: "1.11.0"),
    ],
    targets: [
        .target(
            name: "Datadog-macOS",
            dependencies: [
                "_Datadog_Private-macOS",
            ],
            swiftSettings: [.define("SPM_BUILD")]
        ),
        .target(
            name: "DatadogObjc-macOS",
            dependencies: [
                "Datadog-macOS",
            ]
        ),
        .target(
            name: "_Datadog_Private-macOS"
        ),
        .target(
            name: "DatadogCrashReporting-macOS",
            dependencies: [
                "Datadog-macOS",
                .product(name: "CrashReporter", package: "PLCrashReporter"),
            ]
        )
    ]
)
