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
				let i1 = t1.timeInSeconds
				let t2 = Subtitles.Time(hour: h2, minute: m2, second: s2, millisecond: ms2)
				let i2 = t2.timeInSeconds
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
			let e1 = Subtitles.Time(timeInSeconds: 1)
			let e2 = Subtitles.Time(timeInSeconds: 2)
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

	func testRawSeconds() throws {
		// https://www.calculateme.com/time/hours-minutes-seconds/to-seconds/
		do {
			let t1 = Subtitles.Time(timeInSeconds: 1432)
			XCTAssertEqual(0, t1.hour)
			XCTAssertEqual(23, t1.minute)
			XCTAssertEqual(52, t1.second)
			XCTAssertEqual(0, t1.millisecond)
		}
		do {
			let t1 = Subtitles.Time(timeInSeconds: 7620.201)
			XCTAssertEqual(2, t1.hour)
			XCTAssertEqual(7, t1.minute)
			XCTAssertEqual(0, t1.second)
			XCTAssertEqual(201, t1.millisecond)
		}
		do {
			let e1 = Subtitles.Time(timeInSeconds: 125.6)
			let e2 = Subtitles.Time(timeInSeconds: 125.7)
			XCTAssertTrue(e1 < e2)
		}
		do {
			let t1 = Subtitles.Time(timeInSeconds: 1432.001)
			let t2 = Subtitles.Time(timeInSeconds: 1432.001)
			XCTAssertEqual(t1, t2)
			let t3 = Subtitles.Time(timeInSeconds: 1432.002)
			XCTAssertNotEqual(t1, t3)
			let t4 = Subtitles.Time(timeInSeconds: 1432.00111)
			XCTAssertEqual(t1, t4)

			XCTAssertEqual(Subtitles.Time(timeInSeconds: 0), Subtitles.Time(timeInSeconds: 0))
			XCTAssertEqual(Subtitles.Time(timeInSeconds: 1432), Subtitles.Time(timeInSeconds: 1432.0001))
			XCTAssertNotEqual(Subtitles.Time(timeInSeconds: 1432), Subtitles.Time(timeInSeconds: 1432.001))
			XCTAssertNotEqual(Subtitles.Time(timeInSeconds: 1431.999), Subtitles.Time(timeInSeconds: 1432))
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
		let content = try Subtitles.encode(subtitles, fileExtension: "srt")

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

	func testCue() throws {
		do {
			let cue1 = Subtitles.Cue(
				startTime: Subtitles.Time(timeInSeconds: 10.500),
				endTime: .init(timeInSeconds: 10.600),
				text: "This is a test"
			)

			XCTAssertEqual(0.1, cue1.duration, accuracy: 0.001)

			XCTAssertFalse(cue1.contains(timeInSeconds: 10.4999999))
			XCTAssertTrue(cue1.contains(timeInSeconds: 10.500))
			XCTAssertTrue(cue1.contains(timeInSeconds: 10.501))

			XCTAssertTrue(cue1.contains(timeInSeconds: 10.600))
			XCTAssertFalse(cue1.contains(timeInSeconds: 10.6001))
			XCTAssertFalse(cue1.contains(timeInSeconds: 10.6000000001))
			XCTAssertFalse(cue1.contains(timeInSeconds: 10.601))
		}

		do {
			let cue1 = Subtitles.Cue(
				startTime: Subtitles.Time(timeInSeconds: 10.500),
				endTime: .init(timeInSeconds: 10.600),
				text: "This is a test"
			)
			let cue2 = Subtitles.Cue(
				startTime: Subtitles.Time(timeInSeconds: 10.600),
				endTime: .init(timeInSeconds: 10.700),
				text: "This is the second"
			)
			let sts = Subtitles([cue1, cue2])
			XCTAssertNil(sts.firstCue(containing: 8))

			let sts1 = try XCTUnwrap(sts.firstCue(containing: 10.501))
			XCTAssertEqual(sts1.text, "This is a test")

			let sts2 = try XCTUnwrap(sts.firstCue(containing: 10.601))
			XCTAssertEqual(sts2.text, "This is the second")
		}
	}

	func testBuilding() throws {
		do {
			let cue1 = Subtitles.Cue(startTime: 10, duration: 0.25, text: "hi there")
			XCTAssertEqual(cue1.startTime, .init(timeInSeconds: 10))
			XCTAssertEqual(cue1.duration, 0.25)
			XCTAssertEqual(cue1.endTime, .init(timeInSeconds: 10 + 0.25))
			XCTAssertEqual(cue1.text, "hi there")
		}
	}

	func testNextCue() throws {

		let cue1 = Subtitles.Cue(startTime: 10, duration: 0.25, text: "hi there 1")
		let cue2 = Subtitles.Cue(startTime: 15, duration: 0, text: "hi there 2")

		let ss = Subtitles([cue1, cue2])

		XCTAssertNil(ss.firstCue(containing: 2))
		XCTAssertEqual(0, ss.nextCueIndex(for: 2))

		// Should be nil, as we are inside a cue
		XCTAssertNil(ss.nextCueIndex(for: 10.1))

		XCTAssertNil(ss.firstCue(containing: 12.3))
		XCTAssertEqual(1, ss.nextCueIndex(for: 12.3))

		XCTAssertNil(ss.nextCueIndex(for: 20))

		do {
			var t = try XCTUnwrap(ss.cueType(for: 12.3))
			XCTAssert(t.isInsideCue == false)
			XCTAssertEqual(t.cueIndex, 1)

			t = try XCTUnwrap(ss.cueType(for: 0))
			XCTAssert(t.isInsideCue == false)
			XCTAssertEqual(t.cueIndex, 0)

			t = try XCTUnwrap(ss.cueType(for: 10.15))
			XCTAssert(t.isInsideCue == true)
			XCTAssertEqual(t.cueIndex, 0)

			XCTAssertNil(ss.cueType(for: 16))
		}
	}

	func testStringLines() throws {
		let crLfString = "WEBVTT\r\n\r\n00:00:05.312 --> 00:00:06.729 line:90%,end position:50%,center align:center\r\nIt’s 9:00 a.m.\r\n\r\n00:00:06.729 --> 00:00:08.687 line:90%,end position:50%,center align:center\r\non a Tuesday morning"
		let nlString = "WEBVTT\n\n00:00:05.312 --> 00:00:06.729 line:90%,end position:50%,center align:center\nIt’s 9:00 a.m.\n\n00:00:06.729 --> 00:00:08.687 line:90%,end position:50%,center align:center\non a Tuesday morning"
		let crLFLines = crLfString.lines
		let nlLines = nlString.lines

		XCTAssertEqual(crLFLines, nlLines)
		XCTAssertEqual(crLFLines.count, 7)
	}
}
