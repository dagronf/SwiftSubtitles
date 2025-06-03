import XCTest
@testable import SwiftSubtitles

final class SUBTests: XCTestCase {

	let coder = Subtitles.Coder.SUB()

	func testBasic() throws {
		do {
			let content = "{0}{25}{c:$0000ff}{y:b,u}{f:DeJaVuSans}{s:12}Hello!"
			let subtitles = try coder.decode(content)
			XCTAssertEqual(1, subtitles.cues.count)
		}

		do {
			let content = "{0}{25}{y:i}Hello!|{y:b}How are you?"
			let subtitles = try coder.decode(content)
			XCTAssertEqual(1, subtitles.cues.count)
			XCTAssertEqual(subtitles.cues[0].text, "Hello!\nHow are you?")
		}

		do {
			let customCoder = Subtitles.Coder.SUB(framerate: 60)
			let content = "{0}{25}{y:i}Hello!|{y:b}How are you?"
			let subtitles = try customCoder.decode(content)
			XCTAssertEqual(1, subtitles.cues.count)
			XCTAssertEqual(subtitles.cues[0].text, "Hello!\nHow are you?")
			XCTAssertEqual(subtitles.cues[0].startTimeInSeconds, (0.0 / 60.0), accuracy: 0.001)
			XCTAssertEqual(subtitles.cues[0].endTimeInSeconds, (25.0 / 60.0), accuracy: 0.001)
		}
	}

#if !os(Linux)
	// There's some encoding issue here on linux - just comment it out for the moment

	/*
	 /__w/SwiftSubtitles/SwiftSubtitles/Tests/SwiftSubtitlesTests/SUBTests.swift:37: error: SUBTests.testSUBFile : XCTAssertEqual failed: ("Nenorm‘lne si ma vystraÃil.
	 Kde si bol?") is not equal to ("Nenorm·lne si ma vystraöil.
	 Kde si bol?") -
	 */

	func testSUBFile() throws {
		let fileURL = Bundle.module.url(forResource: "97620", withExtension: "sub")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .macOSRoman)
		XCTAssertEqual(684, subtitles.cues.count)
		XCTAssertEqual(subtitles.cues[475].text, "Nenorm·lne si ma vystraöil.\nKde si bol?")
		XCTAssertEqual(subtitles.cues[475].startTimeInSeconds, (109504.0 / coder.framerate), accuracy: 0.001)
		XCTAssertEqual(subtitles.cues[475].endTimeInSeconds, (109602.0 / coder.framerate), accuracy: 0.001)
	}
#endif
}




