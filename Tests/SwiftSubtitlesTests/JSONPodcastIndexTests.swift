import XCTest
@testable import SwiftSubtitles

final class JSONPodcastIndexTests: XCTestCase {
	func testExample() throws {
		let fileURL = try resourceURL(forResource: "sample", withExtension: "json")
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(3, subtitles.cues.count)
		XCTAssertEqual(Subtitles.Time(timeInSeconds: 2.15), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(timeInSeconds: 2.20), subtitles.cues[0].endTime)
		XCTAssertEqual("This video was recorded and uploaded to Youtube.", subtitles.cues[0].text)

		XCTAssertEqual(Subtitles.Time(timeInSeconds: 2.25), subtitles.cues[2].startTime)
		XCTAssertEqual(Subtitles.Time(timeInSeconds: 2.30), subtitles.cues[2].endTime)
		XCTAssertEqual("I converted the captions from another file.", subtitles.cues[2].text)

		let speakers = subtitles.uniqueSpeakers
		XCTAssertEqual(Set(["Peter"]), speakers)

		let coder = Subtitles.Coder.VTT()
		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)
		XCTAssertEqual(3, decoded.cues.count)
	}

	func testExample2() throws {
		let fileURL = try resourceURL(forResource: "starwars-demo", withExtension: "json")
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)

		XCTAssertEqual(5, subtitles.cues.count)
		
		XCTAssertEqual("Darth Vader", subtitles.cues[0].speaker)
		XCTAssertEqual(0.5, subtitles.cues[0].startTimeInSeconds)
		XCTAssertEqual(0.75, subtitles.cues[0].endTimeInSeconds)
		XCTAssertEqual("I", subtitles.cues[0].text)

		XCTAssertEqual("Luke", subtitles.cues[4].speaker)
		XCTAssertEqual(2.75, subtitles.cues[4].startTimeInSeconds)
		XCTAssertEqual(3.0, subtitles.cues[4].endTimeInSeconds)
		XCTAssertEqual("Nooooo", subtitles.cues[4].text)

		let speakers = subtitles.uniqueSpeakers
		XCTAssertEqual(Set(["Darth Vader", "Luke"]), speakers)

		let enc = Subtitles.Coder.JSONPodcastIndex()
		let encodedData = try enc.encode(subtitles: subtitles, encoding: .utf8)

		let decoded = try enc.decode(encodedData, encoding: .utf8)
		XCTAssertEqual(subtitles, decoded)
	}
}
