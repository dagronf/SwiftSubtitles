import XCTest
@testable import SwiftSubtitles

final class CSVTests: XCTestCase {

	func testDecode() throws {
		let csv = """
1, 00:00:00:599, 00:00:04.160, ">> ALICE: Hi, my name is Alice Miller and this is John Brown"
2, 00:00:04:160, 00:00:06.770, ">> JOHN: and we're the owners of Miller Bakery."
3, 00:00:06.770, 00:00:10.880, ">> ALICE: Today we'll be teaching you how to make
our famous chocolate chip cookies!"
4, 00:00:10.880, 00:00:16.700, "[intro music]"
5, 00:00:16.700, 00:00:21.480, "Okay, so we have all the ingredients laid out here"
"""

		let coder = Subtitles.Coder.CSV()
		let subtitles = try coder.decode(csv)
		XCTAssertEqual(5, subtitles.cues.count)
		XCTAssertEqual(">> ALICE: Hi, my name is Alice Miller and this is John Brown", subtitles.cues[0].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 0, millisecond: 599), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 160), subtitles.cues[0].endTime)

		XCTAssertEqual("Okay, so we have all the ingredients laid out here", subtitles.cues[4].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 16, millisecond: 700), subtitles.cues[4].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 21, millisecond: 480), subtitles.cues[4].endTime)

		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)

		XCTAssertEqual(subtitles, decoded)

		do {
			let content = try coder.encode(subtitles: subtitles)
			//Swift.print(content)

			let recon = try coder.decode(content)
			XCTAssertEqual(5, recon.cues.count)
			XCTAssertEqual(">> ALICE: Hi, my name is Alice Miller and this is John Brown", recon.cues[0].text)
			XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 0, millisecond: 599), recon.cues[0].startTime)
			XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 160), recon.cues[0].endTime)

			XCTAssertEqual(">> ALICE: Today we'll be teaching you how to make\nour famous chocolate chip cookies!", recon.cues[2].text)

			XCTAssertEqual("Okay, so we have all the ingredients laid out here", recon.cues[4].text)
			XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 16, millisecond: 700), recon.cues[4].startTime)
			XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 21, millisecond: 480), recon.cues[4].endTime)
		}
	}

	func testTimesInMilliseconds() throws {
		let csv = """
1, 91216, 93093, "РегалВю ТЕЛЕМАРКЕТИНГ
АНДЕРСЪН - МЕНИДЖЪР"
2, 102727, 104562, "Тук пише, че 5 години сте бил"
3,104646,107232,"мениджър на ресторант ""Ръсти Скапър""."
"""
		let coder = Subtitles.Coder.CSV()
		let subtitles = try coder.decode(csv)
		XCTAssertEqual(3, subtitles.cues.count)
		XCTAssertEqual(subtitles.cues[0].text, "РегалВю ТЕЛЕМАРКЕТИНГ\nАНДЕРСЪН - МЕНИДЖЪР")
		XCTAssertEqual(subtitles.cues[0].position, 1)
		XCTAssertEqual(subtitles.cues[0].startTime, Subtitles.Time(timeInSeconds: 91216 / 1000))
		XCTAssertEqual(subtitles.cues[0].endTime, Subtitles.Time(timeInSeconds: 93093 / 1000))

		XCTAssertEqual(subtitles.cues[1].text, "Тук пише, че 5 години сте бил")
		XCTAssertEqual(subtitles.cues[1].position, 2)
		XCTAssertEqual(subtitles.cues[1].startTime, Subtitles.Time(timeInSeconds: 102727 / 1000))
		XCTAssertEqual(subtitles.cues[1].endTime, Subtitles.Time(timeInSeconds: 104562 / 1000))

		XCTAssertEqual(subtitles.cues[2].text, "мениджър на ресторант \"Ръсти Скапър\".")
		XCTAssertEqual(subtitles.cues[2].position, 3)
		XCTAssertEqual(subtitles.cues[2].startTime, Subtitles.Time(timeInSeconds: 104646 / 1000))
		XCTAssertEqual(subtitles.cues[2].endTime, Subtitles.Time(timeInSeconds: 107232 / 1000))
	}

	func testBasicLoadCSV() throws {
		let fileURL = Bundle.module.url(forResource: "stby", withExtension: "csv")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)

		XCTAssertEqual(7, subtitles.cues.count)
		XCTAssertEqual(subtitles.cues[0].text, "РегалВю ТЕЛЕМАРКЕТИНГ\nАНДЕРСЪН - МЕНИДЖЪР")
		XCTAssertEqual(subtitles.cues[0].position, 1)
		XCTAssertEqual(subtitles.cues[0].startTime, Subtitles.Time(timeInSeconds: 91216 / 1000))
		XCTAssertEqual(subtitles.cues[0].endTime, Subtitles.Time(timeInSeconds: 93093 / 1000))

		XCTAssertEqual(subtitles.cues[6].text, "Какъв е онзи трофей в чантата?")
		XCTAssertEqual(subtitles.cues[6].position, 7)
		XCTAssertEqual(subtitles.cues[6].startTime, Subtitles.Time(timeInSeconds: 119953 / 1000))
		XCTAssertEqual(subtitles.cues[6].endTime, Subtitles.Time(timeInSeconds: 122872 / 1000))
	}

	func testBasicLoadWithLineBreaks() throws {
		let fileURL = try resourceURL(forResource: "captions_edited", withExtension: "csv")
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(6, subtitles.cues.count)

		XCTAssertEqual(subtitles.cues[4].startTime, Subtitles.Time(second: 17, millisecond: 690))
		XCTAssertEqual(subtitles.cues[4].endTime, Subtitles.Time(second: 24, millisecond: 810))
		XCTAssertNil(subtitles.cues[4].speaker)
		XCTAssertEqual(subtitles.cues[4].text, "Next I ran the SBV file through the SBV file\nconverter to produce JSON, HTML, and text")

		// Round trip
		let coder = Subtitles.Coder.CSV()
		let enc = try coder.encode(subtitles: subtitles, encoding: .utf8)
		let dec = try coder.decode(enc, encoding: .utf8)
		XCTAssertEqual(dec, subtitles)
	}
}
