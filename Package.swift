// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SwiftSubtitles",
	platforms: [
		.macOS(.v10_13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "SwiftSubtitles",
			targets: ["SwiftSubtitles"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFRegex", from: "3.1.0"),
		.package(url: "https://github.com/dagronf/TinyCSV", .upToNextMinor(from: "0.5.1"))
	],
	targets: [
		.target(
			name: "SwiftSubtitles",
			dependencies: ["DSFRegex", "TinyCSV"]),
		.testTarget(
			name: "SwiftSubtitlesTests",
			dependencies: ["SwiftSubtitles"],
			resources: [
				.process("resources"),
			]
		),
	]
)
