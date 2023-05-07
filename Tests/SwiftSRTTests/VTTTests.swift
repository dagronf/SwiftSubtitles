import XCTest
@testable import SwiftSRT

final class VTTTests: XCTestCase {
	func testExample() throws {
		let fileURL = Bundle.module.url(forResource: "sample", withExtension: "vtt")!
		let subtitles = try Subtitles(fileURL: fileURL)
		XCTAssertEqual(3, subtitles.entries.count)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 2, second: 15, millisecond: 0), subtitles.entries[0].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 2, second: 20, millisecond: 0), subtitles.entries[0].endTime)
		XCTAssertEqual("- Ta en kopp varmt te.\n- Det är inte varmt.", subtitles.entries[0].text)

		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 2, second: 25, millisecond: 0), subtitles.entries[2].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 2, second: 30, millisecond: 0), subtitles.entries[2].endTime)
		XCTAssertEqual("This is the third chapter", subtitles.entries[2].title)
		XCTAssertEqual("- Ta en kopp", subtitles.entries[2].text)

		let coder = Subtitles.VTTCodable()
		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)
		XCTAssertEqual(3, decoded.entries.count)

		XCTAssertEqual(subtitles, decoded)
	}

	func testDecode() throws {
		let vtt = """
WEBVTT

00:01.000 --> 00:04.000
- Never drink liquid nitrogen.

00:05.000 --> 00:09.000
- It will perforate your stomach.
- You could die.
"""
		let coder = Subtitles.VTTCodable()
		let subtitles = try coder.decode(vtt)
		XCTAssertEqual(2, subtitles.entries.count)
		XCTAssertEqual("- Never drink liquid nitrogen.", subtitles.entries[0].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 1, millisecond: 0), subtitles.entries[0].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 0), subtitles.entries[0].endTime)

		XCTAssertEqual("- It will perforate your stomach.\n- You could die.", subtitles.entries[1].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 5, millisecond: 0), subtitles.entries[1].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 9, millisecond: 0), subtitles.entries[1].endTime)

		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)
		XCTAssertEqual(2, decoded.entries.count)

		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 1, millisecond: 0), subtitles.entries[0].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 0), subtitles.entries[0].endTime)
		XCTAssertEqual("- Never drink liquid nitrogen.", decoded.entries[0].text)

		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 5, millisecond: 0), subtitles.entries[1].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 9, millisecond: 0), subtitles.entries[1].endTime)
		XCTAssertEqual("- It will perforate your stomach.\n- You could die.", decoded.entries[1].text)
	}

	func testMicrosoftTests() throws {
		// https://support.microsoft.com/en-us/office/create-closed-captions-for-a-video-b1cfb30f-5b00-4435-beeb-2a25e115024b
		let content = """
WEBVTT

00:00:01.000 --> 00:00:05.330
Good day everyone, my name is June Doe.

00:00:07.608 --> 00:00:15.290
This video teaches you how to
build a sandcastle on any beach.
"""

		let coder = Subtitles.VTTCodable()
		let subtitles = try coder.decode(content)
		XCTAssertEqual(2, subtitles.entries.count)
		XCTAssertEqual(Subtitles.Time(second: 1, millisecond: 0), subtitles.entries[0].startTime)
		XCTAssertEqual(Subtitles.Time(second: 5, millisecond: 330), subtitles.entries[0].endTime)
		XCTAssertEqual("Good day everyone, my name is June Doe.", subtitles.entries[0].text)
		XCTAssertEqual(Subtitles.Time(second: 7, millisecond: 608), subtitles.entries[1].startTime)
		XCTAssertEqual(Subtitles.Time(second: 15, millisecond: 290), subtitles.entries[1].endTime)
		XCTAssertEqual("This video teaches you how to\nbuild a sandcastle on any beach.", subtitles.entries[1].text)

		// Round trip
		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)
		XCTAssertEqual(2, decoded.entries.count)
		XCTAssertEqual(subtitles, decoded)
	}
}
