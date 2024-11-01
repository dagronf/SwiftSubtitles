import XCTest
@testable import SwiftSubtitles

final class LRCTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testBasic() throws {
		let text = """
			[00:12.00]Line 1 lyrics
			[00:17.20]Line 2 lyrics

			[00:21.10][00:45.10]Repeating lyrics (e.g. chorus)
			[88:11.22]Minutes > 59
			"""

		let subs = try Subtitles.Coder.LRC()
			.decode(text)
			.startTimeSorted

		XCTAssertEqual(5, subs.cues.count)

		XCTAssertEqual("Line 1 lyrics", subs.cues[0].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 12, millisecond: 0), subs.cues[0].startTime)
		XCTAssertEqual(0, subs.cues[0].duration)

		XCTAssertEqual("Line 2 lyrics", subs.cues[1].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 17, millisecond: 200), subs.cues[1].startTime)
		XCTAssertEqual(0, subs.cues[1].duration)

		XCTAssertEqual("Repeating lyrics (e.g. chorus)", subs.cues[2].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 21, millisecond: 100), subs.cues[2].startTime)
		XCTAssertEqual(0, subs.cues[2].duration)

		XCTAssertEqual("Repeating lyrics (e.g. chorus)", subs.cues[3].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 45, millisecond: 100), subs.cues[3].startTime)
		XCTAssertEqual(0, subs.cues[3].duration)

		XCTAssertEqual("Minutes > 59", subs.cues[4].text)
		XCTAssertEqual(Subtitles.Time(hour: 1, minute: 28, second: 11, millisecond: 220), subs.cues[4].startTime)
		XCTAssertEqual(0, subs.cues[4].duration)
	}

	func testBasicFile() throws {
		let fileURL = Bundle.module.url(forResource: "espresso", withExtension: "lrc")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(56, subtitles.cues.count)
	}

	func testJapaneseFile() throws {
		let fileURL = Bundle.module.url(forResource: "ZUTOMAYO - Can't Be Right", withExtension: "lrc")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(50, subtitles.cues.count)

		XCTAssertEqual("考え続けたい", subtitles.cues[3].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 9, millisecond: 310), subtitles.cues[3].startTime)
		XCTAssertEqual(0, subtitles.cues[3].duration)

		let c49 = subtitles.cues[49]
		XCTAssertEqual("", c49.text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 3, second: 19, millisecond: 140), c49.startTime)
		XCTAssertEqual(0, c49.duration)
	}

	func testMillisecondsSupport() throws {
		let str = """
			[COLOUR]0xFF66FF
			[00:03.120]Owaranai
			[00:05.548]mugen no hikari ...
			[00:09.927]
			[00:21.016]taeran ninmu
			[00:23.764]surechigau sadame
			[00:26.564]nokosareteta
			[00:28.374]rakuen no atochi
			[00:32.083]
			[00:32.291]kanashimi no melody
			[00:35.226]nami yomu tobi
			[00:37.482]sokoni saiteta
			[00:39.850]
			[00:40.275]chiisana baby's tears
			[00:43.746]
			[00:44.006]donna umi ga
			[00:46.531]tsumatteru hoshii
			[00:49.353]tsunaida te wo
			[00:52.183]furikitta
			[00:55.363]
			[00:56.644]ashita
			[00:57.895]kagayaki wo
			[00:59.266]torimodosu
			[01:01.031]tame ni
			[01:02.304]
			[01:02.401]negai wo nosete
			[01:05.075]tokihanatsu
			[01:07.562]
			[01:08.016]owari
			[01:09.133]wo shiranai
			[01:10.854]utsukushiki hane ni
			[01:13.557]
			[01:13.699]furisosogu
			[01:16.030]mugen no hikari
			[01:19.485]
			"""

		let subs = try Subtitles.Coder.LRC().decode(str)

		XCTAssertEqual(34, subs.cues.count)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 1, second: 13, millisecond: 699), subs.cues[31].startTime)
		XCTAssertEqual("furisosogu", subs.cues[31].text)
	}

	func testMixedLineTimeFormats() throws {
		let content = "[00:31.01][00:55.710][01:22.101]Mixed time line"
		let subs = try Subtitles.Coder.LRC().decode(content)
		// 3 cues
		XCTAssertEqual(3, subs.cues.count)
		// All text should be the same
		XCTAssertEqual(1, Set(subs.cues.map { $0.text }).count)
		XCTAssertEqual("Mixed time line", subs.cues[0].text)

		XCTAssertEqual(Subtitles.Time(second: 31, millisecond: 10), subs.cues[0].startTime)
		XCTAssertEqual(0, subs.cues[0].duration)
		XCTAssertEqual(Subtitles.Time(second: 55, millisecond: 710), subs.cues[1].startTime)
		XCTAssertEqual(0, subs.cues[1].duration)
		XCTAssertEqual(Subtitles.Time(minute: 1, second: 22, millisecond: 101), subs.cues[2].startTime)
		XCTAssertEqual(0, subs.cues[2].duration)
	}

	func testBasicEncode() throws {
		// Read in content
		let fileURL = try resourceURL(forResource: "captions_edited", withExtension: "csv")
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(6, subtitles.cues.count)

		try Subtitles.Coder.LRC.TimeFormat.allCases.forEach { format in
			let lrc = Subtitles.Coder.LRC(timeFormat: format)

			let lrcEncoded = try lrc.encode(subtitles: subtitles)
			let lrcDecoded = try lrc.decode(lrcEncoded)
			XCTAssertEqual(6, lrcDecoded.cues.count)

			let c0 = lrcDecoded.cues[0]
			XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 0, millisecond: 940), c0.startTime)
			XCTAssertEqual("This is a test of the SBV file converter.", c0.text)
			let c1 = lrcDecoded.cues[1]
			XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 5, millisecond: 050), c1.startTime)
			XCTAssertEqual("This video was recorded and uploaded to Youtube.", c1.text)
			let c3 = lrcDecoded.cues[3]
			switch format {
			case .minutesSecondsHundredths:
				XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 14, millisecond: 070), c3.startTime)
			case .minutesSecondsMilliseconds:
				XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 14, millisecond: 079), c3.startTime)
			}
			XCTAssertEqual("I downloaded the captions as an SBV file.", c3.text)
		}
	}
}
