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
		let coder = Subtitles.SBVCodable()
		let subtitles = try coder.decode(sbv)
		XCTAssertEqual(5, subtitles.entries.count)
		XCTAssertEqual(">> ALICE: Hi, my name is Alice Miller and this is John Brown", subtitles.entries[0].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 0, millisecond: 599), subtitles.entries[0].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 160), subtitles.entries[0].endTime)

		XCTAssertEqual("Okay, so we have all the ingredients laid out here", subtitles.entries[4].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 16, millisecond: 700), subtitles.entries[4].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 21, millisecond: 480), subtitles.entries[4].endTime)

		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)

		XCTAssertEqual(subtitles, decoded)
	}

	func testDecodeFailure() throws {
		let sbv = """
0:00:00.599,0:00:04.160

0:00:04.160,0:00:06.770
>> JOHN: and we're the owners of Miller Bakery.
"""
		let coder = Subtitles.SBVCodable()
		XCTAssertThrowsError(try coder.decode(sbv))
	}
}
