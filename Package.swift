// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Laiban",
    defaultLocalization: "sv",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "Laiban",               targets: ["Laiban"]),
        .library(name: "TextAutoCorrector",    targets: ["TextAutoCorrector"]),
        .library(name: "SharedActivities",     targets: ["SharedActivities"]),
        .library(name: "UDPipe",               targets: ["UDPipe"])
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.2.3"),
        .package(url: "https://github.com/helsingborg-stad/spm-daisy", from: "1.0.4"),
        .package(url: "https://github.com/apple/ml-stable-diffusion.git", from: "1.1.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .target(
            name: "Laiban",
            dependencies: [
                "SDWebImageSwiftUI",
                "SharedActivities",
                "TextAutoCorrector",
                "UDPipe",
                "ZIPFoundation",
                .product(name: "TTS",                package: "spm-daisy"),
                .product(name: "Shout",              package: "spm-daisy"),
                .product(name: "Assistant",          package: "spm-daisy"),
                .product(name: "AudioSwitchboard",   package: "spm-daisy"),
                .product(name: "TextTranslator",     package: "spm-daisy"),
                .product(name: "PublicCalendar",     package: "spm-daisy"),
                .product(name: "Meals",              package: "spm-daisy"),
                .product(name: "Instagram",          package: "spm-daisy"),
                .product(name: "Weather",            package: "spm-daisy"),
                .product(name: "Analytics",          package: "spm-daisy"),
                .product(name: "StableDiffusion",    package: "ml-stable-diffusion")
            ],
            path: "Laiban",
            exclude: ["Modules/Movement/Tests"],
            resources: [
                .process("Shared/Resources"),
                .process("StandaloneUIComponents/ClockUI/Sources/Resources"),
                .process("StandaloneUIComponents/ThermometerUI/Sources/Resources"),
                .process("Modules/Calendar/Sources/Resources"),
                .process("Modules/Memory/Sources/Resources"),
                .process("Modules/FoodWaste/Sources/Resources"),
                .process("Modules/Singalong/Sources/Resources"),
                .process("Modules/TrashMonsters/Sources/Resources"),
                .process("Modules/Recreation/Sources/Resources"),
                .process("Modules/Movement/Sources/Resources"),
                .process("Modules/Time/Sources/Resources"),
                .process("Modules/Noticeboard/Sources/Resources"),
                .process("Modules/Outdoors/Sources/Resources/ClothesAssets.xcassets"),
                .copy("Modules/Outdoors/Sources/Resources/AttireSuggestionPredictionModel.mlmodelc"),
                .process("Modules/Food/Sources/Resources"),
                .process("Modules/UNDP/Sources/Resources")
            ]
        ),
        .target(name: "UDPipe",                     path: "UDPipe/Sources"),
        .target(name: "TextAutoCorrector",          path: "TextAutoCorrector/Sources"),
        .target(name: "SharedActivities",           dependencies: [.product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI")],          path: "SharedActivities/Sources",           resources: [.process("Resources")]),
        .testTarget(name: "MovementTests", dependencies: ["Laiban"], path: "Laiban/Modules/Movement/Tests")
    ]
)
