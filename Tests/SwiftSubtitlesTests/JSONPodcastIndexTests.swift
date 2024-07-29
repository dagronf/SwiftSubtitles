import XCTest
@testable import SwiftSubtitles

final class JSONPodcastIndexTests: XCTestCase {
    func testExample() throws {
        let fileURL = Bundle.module.url(forResource: "sample", withExtension: "json")!
        let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
        XCTAssertEqual(3, subtitles.cues.count)
        XCTAssertEqual(Subtitles.Time(timeInSeconds: 2.15), subtitles.cues[0].startTime)
        XCTAssertEqual(Subtitles.Time(timeInSeconds: 2.20), subtitles.cues[0].endTime)
        XCTAssertEqual("This video was recorded and uploaded to Youtube.", subtitles.cues[0].text)

        XCTAssertEqual(Subtitles.Time(timeInSeconds: 2.25), subtitles.cues[2].startTime)
        XCTAssertEqual(Subtitles.Time(timeInSeconds: 2.30), subtitles.cues[2].endTime)
        XCTAssertEqual("I converted the captions from another file.", subtitles.cues[2].text)

        let coder = Subtitles.Coder.VTT()
        let encoded = try coder.encode(subtitles: subtitles)
        let decoded = try coder.decode(encoded)
        XCTAssertEqual(3, decoded.cues.count)
    }
}
