import XCTest
@testable import SwiftSubtitles

final class JSONTests: XCTestCase {

	func testJSON() throws {
		let fileURL = Bundle.module.url(forResource: "captions", withExtension: "sbv")!
		let subtitles = try Subtitles(fileURL: fileURL)

		let coder = Subtitles.Coder.JSON()
		let content = try coder.encode(subtitles: subtitles)
		XCTAssert(content.count > 0)

		let decoded = try coder.decode(content)

		XCTAssertEqual(subtitles, decoded)
	}
}
