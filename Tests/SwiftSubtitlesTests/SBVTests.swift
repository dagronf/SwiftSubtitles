import XCTest
@testable import SwiftSubtitles

final class SBVTests: XCTestCase {

	func testDecode() throws {
		let sbv = """
0:00:00.599,0:00:04.160
>> ALICE: Hi, my name is Alice Miller and this is John Brown

0:00:04.160,0:00:06.770
>> JOHN: and we're the owners of Miller Bakery.

0:00:06.770,0:00:10.880
>> ALICE: Today we'll be teaching you how to make
our famous chocolate chip cookies!

0:00:10.880,0:00:16.700
[intro music]

0:00:16.700,0:00:21.480
Okay, so we have all the ingredients laid out here
"""
		let coder = Subtitles.Coder.SBV()
		let subtitles = try coder.decode(sbv)
		XCTAssertEqual(5, subtitles.cues.count)
		XCTAssertEqual(">> ALICE: Hi, my name is Alice Miller and this is John Brown", subtitles.cues[0].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 0, millisecond: 599), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 160), subtitles.cues[0].endTime)

		XCTAssertEqual("Okay, so we have all the ingredients laid out here", subtitles.cues[4].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 16, millisecond: 700), subtitles.cues[4].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 21, millisecond: 480), subtitles.cues[4].endTime)

		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)

		XCTAssertEqual(subtitles, decoded)
	}

	func testDecodeFromFile() throws {
		let fileURL = Bundle.module.url(forResource: "captions", withExtension: "sbv")!
		let subtitles = try Subtitles(fileURL: fileURL, expectedEncoding: .utf8)
		XCTAssertEqual(subtitles.cues.count, 6)

		XCTAssertEqual(subtitles.cues[0].startTime, Subtitles.Time(millisecond: 940))
		XCTAssertEqual(subtitles.cues[0].endTime, Subtitles.Time(second: 5, millisecond: 50))
		XCTAssertEqual(subtitles.cues[0].text, "This is a test of the SBV file converter.")
	}

	func testDecodeFromNonUTF8File() throws {
		let fileURL = Bundle.module.url(forResource: "captions-LE", withExtension: "sbv")!
		let subtitles = try Subtitles(fileURL: fileURL, expectedEncoding: .utf16LittleEndian)
		XCTAssertEqual(subtitles.cues.count, 6)
	}

	func testDecodeFailure() throws {
		let sbv = """
0:00:00.599,0:00:04.160

0:00:04.160,0:00:06.770
>> JOHN: and we're the owners of Miller Bakery.
"""
		let coder = Subtitles.Coder.SBV()
		XCTAssertThrowsError(try coder.decode(sbv))
	}
}
