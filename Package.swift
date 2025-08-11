// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "SwiftSubtitles",
	platforms: [
		.macOS(.v10_13),
		.iOS(.v12),
		.tvOS(.v12),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "SwiftSubtitles",
			targets: ["SwiftSubtitles"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFRegex", from: "4.0.0"),
		.package(url: "https://github.com/dagronf/TinyCSV", .upToNextMinor(from: "1.0.0")),
		.package(url: "https://github.com/dagronf/BytesParser", from: "3.2.1"),
	],
	targets: [
		.target(
			name: "SwiftSubtitles",
			dependencies: ["DSFRegex", "TinyCSV", "BytesParser"],
			resources: [
				.copy("PrivacyInfo.xcprivacy"),
			]
		),
		.testTarget(
			name: "SwiftSubtitlesTests",
			dependencies: [ "SwiftSubtitles" ],
			resources: [
				.process("resources"),
			]
		),
	]
)
