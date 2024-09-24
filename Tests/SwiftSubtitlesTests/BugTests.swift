import XCTest
@testable import SwiftSubtitles

final class BugTests: XCTestCase {

	func testZeroLengthCueImport() throws {

		// https://github.com/dagronf/SwiftSubtitles/issues/11

		let fileURL = Bundle.module.url(forResource: "26-transcript", withExtension: "srt")!

		// This file has a number of zero length entries.
		let orig = try Subtitles(fileURL: fileURL, encoding: .macOSRoman)
		XCTAssertEqual(877, orig.cues.count)

		let index = try XCTUnwrap(orig.cueIndex(forPosition: 201))
		XCTAssertEqual(0, orig.cues[index].duration)

		let zeroLengthIndexes = orig.cuesOfZeroLength()
		XCTAssertEqual(1, zeroLengthIndexes.count)
		XCTAssertEqual(201, zeroLengthIndexes[0].position)

		// Round trip and check
		let encoded = try Subtitles.Coder.SRT().encode(subtitles: orig)
		let decoded = try Subtitles.Coder.SRT().decode(encoded)
		XCTAssertEqual(877, decoded.cues.count)

		let index2 = try XCTUnwrap(decoded.cueIndex(forPosition: 201))
		XCTAssertEqual(0, decoded.cues[index2].duration)
	}

	func testZeroLengthCueImport2() throws {

		// https://github.com/dagronf/SwiftSubtitles/issues/11

		let st = Subtitles([
			.init(startTime: .init(timeInSeconds: 1), endTime: .init(timeInSeconds: 0.5), text: "asdf"),
			.init(startTime: .init(timeInSeconds: 2), endTime: .init(timeInSeconds: 2.001), text: "asdf")
		])
		// Check that the cue initializer correctly shifts the end time correctly
		XCTAssertTrue(st.cues[0].isZeroLength())
		XCTAssertFalse(st.cues[1].isZeroLength())
		XCTAssertEqual(0.001, st.cues[1].duration, accuracy: 0.0001)
	}
}
