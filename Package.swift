// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SwiftSRT",
	platforms: [
		.macOS(.v10_13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v4)
	],
	products: [
		.library(
			name: "SwiftSRT",
			targets: ["SwiftSRT"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFRegex", from: "3.1.0")
	],
	targets: [
		.target(
			name: "SwiftSRT",
			dependencies: ["DSFRegex"]),
		.testTarget(
			name: "SwiftSRTTests",
			dependencies: ["SwiftSRT"],
			resources: [
				.process("resources"),
			]
		),
	]
)
