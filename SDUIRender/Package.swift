// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "SDUIShowcase",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SDUIRenderSwift", type: .dynamic, targets: ["SDUIRenderSwift"]),
        .library(name: "SDUIShowcase", type: .dynamic, targets: ["SDUIShowcase"]),
        .library(name: "ShowcaseApp", type: .dynamic, targets: ["ShowcaseApp"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.9.2"),
        .package(url: "https://source.skip.tools/skip-ui.git", from: "1.0.0"),
        .package(url: "https://github.com/inditex/mlb-xmediaplayerios", .upToNextMajor(from: "5.3.0")),
        .package(url: "https://github.com/inditex/mlb-itxmediaplayerios", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(name: "SDUIRenderSwift", dependencies: [
            .product(name: "SkipUI", package: "skip-ui"),
            .product(name: "XMediaPlayer",  package: "mlb-xmediaplayerios",  condition: .when(platforms: [.iOS])),
            .product(name: "ITXMediaPlayer", package: "mlb-itxmediaplayerios", condition: .when(platforms: [.iOS]))
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .target(name: "SDUIShowcase", dependencies: [
            "SDUIRenderSwift",
            .product(name: "SkipUI", package: "skip-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .target(name: "ShowcaseApp", dependencies: [
            "SDUIShowcase",
            .product(name: "SkipUI", package: "skip-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(name: "SDUIRenderSwiftTests", dependencies: [
            "SDUIRenderSwift",
            .product(name: "SkipUI", package: "skip-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
