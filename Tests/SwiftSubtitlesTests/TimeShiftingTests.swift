import XCTest
@testable import SwiftSubtitles


final class TimeShiftingTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testInsertDuration() throws {
		let fileURL = Bundle.module.url(forResource: "upc-video-subtitles-en", withExtension: "vtt")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)

		XCTAssertEqual(8, subtitles.cues.count)

		do {
			// Insert at the start
			let n = subtitles.timeShifting(by: 1)
			(0 ..< subtitles.cues.count).forEach { index in
				XCTAssertEqual(subtitles.cues[index].startTimeInSeconds + 1, n.cues[index].startTimeInSeconds)
				XCTAssertEqual(subtitles.cues[index].endTimeInSeconds + 1, n.cues[index].endTimeInSeconds)
			}
		}

		do {
			// Insert halfway through the first one (inserting 1 second of time at 4 seconds into the subtitles)
			let n = subtitles.timeShifting(by: 1, at: 4)
			XCTAssertEqual(subtitles.cues[0].startTimeInSeconds, n.cues[0].startTimeInSeconds)
			XCTAssertEqual(subtitles.cues[0].endTimeInSeconds + 1, n.cues[0].endTimeInSeconds)
			(1 ..< subtitles.cues.count).forEach { index in
				XCTAssertEqual(subtitles.cues[index].startTimeInSeconds + 1, n.cues[index].startTimeInSeconds)
				XCTAssertEqual(subtitles.cues[index].endTimeInSeconds + 1, n.cues[index].endTimeInSeconds)
			}
		}

		do {
			// Insert inbetween the first two
			let n = subtitles.timeShifting(by: 1, at: 5.5)
			XCTAssertEqual(subtitles.cues[0].startTimeInSeconds, n.cues[0].startTimeInSeconds)
			XCTAssertEqual(subtitles.cues[0].endTimeInSeconds, n.cues[0].endTimeInSeconds)
			(1 ..< subtitles.cues.count).forEach { index in
				XCTAssertEqual(subtitles.cues[index].startTimeInSeconds + 1, n.cues[index].startTimeInSeconds)
				XCTAssertEqual(subtitles.cues[index].endTimeInSeconds + 1, n.cues[index].endTimeInSeconds)
			}
		}

		do {
			// Insert after all cues (should have no changes)
			let n = subtitles.timeShifting(by: 1, at: 40)
			(0 ..< subtitles.cues.count).forEach { index in
				XCTAssertEqual(subtitles.cues[index], n.cues[index])
				XCTAssertEqual(subtitles.cues[index], n.cues[index])
			}
		}
	}

	func testShiftCuesBackInTime() throws {
		let fileURL = Bundle.module.url(forResource: "upc-video-subtitles-en", withExtension: "vtt")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		do {
			// Shift the cues back by 1.5 seconds
			let n = subtitles.timeShifting(by: -1.5)
			(0 ..< subtitles.cues.count).forEach { index in
				XCTAssertEqual(subtitles.cues[index].startTimeInSeconds - 1.5, n.cues[index].startTimeInSeconds)
				XCTAssertEqual(subtitles.cues[index].endTimeInSeconds - 1.5, n.cues[index].endTimeInSeconds)
			}

			let v = n.removingInvalidCues()
			XCTAssertEqual(8, v.cues.count)
		}

		do {
			// Shift the cues back by 7 seconds
			let n = subtitles.timeShifting(by: -7, at: 0)

			XCTAssertEqual(0, n.cues[0].startTimeInSeconds)
			XCTAssertEqual(0, n.cues[0].endTimeInSeconds)
			XCTAssertEqual(0, n.cues[1].startTimeInSeconds)
			XCTAssertEqual(2, n.cues[1].endTimeInSeconds)
			XCTAssertEqual(4, n.cues[2].startTimeInSeconds)
			XCTAssertEqual(7, n.cues[2].endTimeInSeconds)

			let v = n.removingInvalidCues()
			XCTAssertEqual(7, v.cues.count)   // First cue was zero length, thus invalid
		}

		do {
			// Shift the cues back by 7 seconds
			let n = subtitles.timeShifting(by: -1, at: 13)

			XCTAssertEqual(3.5, n.cues[0].startTimeInSeconds)
			XCTAssertEqual(5.0, n.cues[0].endTimeInSeconds)
			XCTAssertEqual(6.0, n.cues[1].startTimeInSeconds)
			XCTAssertEqual(9.0, n.cues[1].endTimeInSeconds)
			XCTAssertEqual(11.0, n.cues[2].startTimeInSeconds)
			XCTAssertEqual(13.0, n.cues[2].endTimeInSeconds)
			XCTAssertEqual(13.5, n.cues[3].startTimeInSeconds)
			XCTAssertEqual(17.0, n.cues[3].endTimeInSeconds)

			let v = n.removingInvalidCues()
			XCTAssertEqual(8, v.cues.count)   // First cue was zero length, thus invalid
		}
	}
}
