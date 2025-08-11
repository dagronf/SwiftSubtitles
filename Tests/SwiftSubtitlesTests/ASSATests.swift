import XCTest
@testable import SwiftSubtitles

final class ASSATests: XCTestCase {
	func testBasic1() throws {
		let fileURL = Bundle.module.url(forResource: "desc", withExtension: "ass")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		assert(subtitles.cues.count == 3)

		XCTAssertEqual(Subtitles.Time(), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(minute: 3), subtitles.cues[0].endTime)
		XCTAssertEqual(180, subtitles.cues[0].duration)

		XCTAssertEqual(Subtitles.Time(minute: 3), subtitles.cues[1].startTime)
		XCTAssertEqual(Subtitles.Time(minute: 3, second: 30), subtitles.cues[1].endTime)
		XCTAssertEqual(30, subtitles.cues[1].duration)

		XCTAssertEqual(Subtitles.Time(minute: 3, second: 30), subtitles.cues[2].startTime)
		XCTAssertEqual(Subtitles.Time(minute: 3, second: 30, millisecond: 100), subtitles.cues[2].endTime)
		XCTAssertEqual(0.100, subtitles.cues[2].duration, accuracy: 0.000001)
	}

	func testBasic2() throws {
		let fileURL = Bundle.module.url(forResource: "time", withExtension: "ass")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(9, subtitles.cues.count)
	}

	func testReal1() throws {
		let fileURL = Bundle.module.url(forResource: "sample1", withExtension: "ass")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(2, subtitles.cues.count)

		XCTAssertEqual(#"Le rugissement des larmes !\NTu es mon ami."#, subtitles.cues[0].text)
		XCTAssertEqual(Subtitles.Time(timeString: "00:01:41.70"), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(timeString: "00:01:46.84"), subtitles.cues[0].endTime)

		XCTAssertEqual(#"Est-ce vraiment Naruto ?"#, subtitles.cues[1].text)
		XCTAssertEqual(Subtitles.Time(timeString: "00:02:00.99"), subtitles.cues[1].startTime)
		XCTAssertEqual(Subtitles.Time(timeString: "00:02:02.87"), subtitles.cues[1].endTime)
	}

	func testDetectLoadSSA() throws {
		let fileURL = Bundle.module.url(forResource: "sample1", withExtension: "ssa")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(2, subtitles.cues.count)
	}
}
