import XCTest
@testable import SwiftSubtitles

final class CommonTests: XCTestCase {

	func testTimeSorting() throws {

		do {
			(0 ... 10000).forEach { _ in
				let h1  = UInt.random(in: 0 ..< 60)
				let m1  = UInt.random(in: 0 ..< 60)
				let s1  = UInt.random(in: 0 ..< 60)
				let ms1 = UInt.random(in: 0 ..< 1000)
				let h2  = UInt.random(in: 0 ..< 60)
				let m2  = UInt.random(in: 0 ..< 60)
				let s2  = UInt.random(in: 0 ..< 60)
				let ms2 = UInt.random(in: 0 ..< 1000)
				let t1 = Subtitles.Time(hour: h1, minute: m1, second: s1, millisecond: ms1)
				let i1 = t1.timeInterval
				let t2 = Subtitles.Time(hour: h2, minute: m2, second: s2, millisecond: ms2)
				let i2 = t2.timeInterval
				XCTAssertEqual(t1 < t2, i1 < i2)
			}
		}

		do {
			let e1 = Subtitles.Time(hour: 54, minute: 43, second: 42, millisecond: 402)
			let e2 = Subtitles.Time(hour: 26, minute: 32, second: 16, millisecond: 869)
			XCTAssertTrue(e2 < e1)
			XCTAssertLessThan(e2, e1)

			let e3 = Subtitles.Time(hour: 54, minute: 43, second: 42, millisecond: 402)
			XCTAssertEqual(e1, e3)
		}

		do {
			let e1 = Subtitles.Time(interval: 1)
			let e2 = Subtitles.Time(interval: 2)
			XCTAssertLessThan(e1, e2)
		}

		do {
			let e1 = Subtitles.Time(hour: 2, minute: 3, second: 10, millisecond: 500)
			let e2 = Subtitles.Time(hour: 1, minute: 3, second: 10, millisecond: 500)
			XCTAssertLessThan(e2, e1)

			let e3 = Subtitles.Time(hour: 1, minute: 3, second: 10, millisecond: 500)
			XCTAssertFalse(e2 < e3)
			XCTAssertFalse(e3 < e2)
			XCTAssertEqual(e2, e3)
		}

		do {
			let e1 = Subtitles.Time(minute: 3, second: 10, millisecond: 500)
			let e2 = Subtitles.Time(hour: 1, minute: 3, second: 10, millisecond: 500)
			XCTAssertTrue(e1 < e2)
		}
	}

	func testDoco1() throws {
			let entry1 = Subtitles.Cue(
				position: 1,
				startTime: Subtitles.Time(minute: 10),
				endTime: Subtitles.Time(minute: 11),
				text: "점점 더 많아지는\n시민들의 성난 목소리로..."
			)

			let entry2 = Subtitles.Cue(
				position: 2,
				startTime: Subtitles.Time(minute: 13, second: 5),
				endTime: Subtitles.Time(minute: 15, second: 10, millisecond: 101),
				text: "Second entry"
			)

			let subtitles = Subtitles([entry1, entry2])

			// Encode based on the subtitle file extension
			let content = try Subtitles.encode(fileExtension: "srt", subtitles: subtitles)

			// Encode using an explicit coder
			let coder = Subtitles.Coder.SRT()
			let content2 = try coder.encode(subtitles: subtitles)

			XCTAssert(content2.count > 0)
			XCTAssertEqual(content, content2)
	}

	func testDoco2() throws {
		let subtitleContent = """
1
00:00:03,400 --> 00:00:06,177
In this lesson, we're going to
be talking about finance. And

2
00:00:06,177 --> 00:00:10,009
one of the most important aspects
of finance is interest.

3
00:00:10,009 --> 00:00:13,655
When I go to a bank or some
other lending institution
"""

		let coder = Subtitles.Coder.SRT()
		let subtitles = try coder.decode(subtitleContent)

		XCTAssertEqual(3, subtitles.cues.count)
		XCTAssertEqual(subtitles.cues[0].startTime, Subtitles.Time(second: 3, millisecond: 400))
		XCTAssertEqual(subtitles.cues[0].endTime, Subtitles.Time(second: 6, millisecond: 177))
		XCTAssertEqual(subtitles.cues[0].text, "In this lesson, we're going to\nbe talking about finance. And")
	}
}
