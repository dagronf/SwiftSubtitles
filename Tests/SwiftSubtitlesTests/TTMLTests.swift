import XCTest
@testable import SwiftSubtitles

final class TTMLTests: XCTestCase {

	func testBasic() throws {

		let text = """
<tt xml:lang="en" xmlns="http://www.w3.org/ns/ttml"
	 xmlns:tts="http://www.w3.org/ns/ttml#styling">
<head>
 <layout>
	<region xml:id="rTop"    tts:origin="10% 10%" tts:extent="80% 20%"/>
	<region xml:id="rMiddle" tts:origin="10% 40%" tts:extent="80% 20%"/>
	<region xml:id="rBottom" tts:origin="10% 70%" tts:extent="80% 20%"/>
 </layout>
</head>
<body>
  <div xml:lang="en">
	 <p begin="0.76s" end="3.20s" region="rTop">
		I sent a message to the fish:
	 </p>
	 <p begin="3.20s" end="6.61s" region="rMiddle">
		I told them "This is what I wish."
	 </p>
	 <p begin="6.61s" end="9.93s" region="r1Bottom">
		The little fishes of the sea,
	 </p>
	 <p begin="9.93s" end="12.35s" region="r2Middle">
		They sent an answer back to me.
	 </p>
  </div> 
</body>
</tt>
"""

		let t = try Subtitles.Coder.TTML().decode(text)

		XCTAssertEqual(4, t.cues.count)

		XCTAssertEqual(Subtitles.Time(millisecond: 760), t.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(second: 3, millisecond: 200), t.cues[0].endTime)
		XCTAssertEqual("I sent a message to the fish:", t.cues[0].text)

		XCTAssertEqual(Subtitles.Time(second: 3, millisecond: 200), t.cues[1].startTime)
		XCTAssertEqual(Subtitles.Time(second: 6, millisecond: 610), t.cues[1].endTime)
	}

	func testBasic1() throws {
		let fileURL = try resourceURL(forResource: "sample1", withExtension: "ttml")
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(5, subtitles.cues.count)

		XCTAssertEqual(Subtitles.Time(millisecond: 0), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(second: 8), subtitles.cues[0].endTime)
		XCTAssertEqual("Lorem ipsum dolor sit", subtitles.cues[0].text)

		XCTAssertEqual(Subtitles.Time(second: 4), subtitles.cues[1].startTime)
		XCTAssertEqual(Subtitles.Time(second: 12), subtitles.cues[1].endTime)
		XCTAssertEqual("Amet consectetur adipiscing elit", subtitles.cues[1].text)

		XCTAssertEqual(Subtitles.Time(second: 8), subtitles.cues[2].startTime)
		XCTAssertEqual(Subtitles.Time(second: 18), subtitles.cues[2].endTime)
		XCTAssertEqual("Sed do eiusmod tempor incididunt labore", subtitles.cues[2].text)

		XCTAssertEqual(Subtitles.Time(second: 14), subtitles.cues[3].startTime)
		XCTAssertEqual(Subtitles.Time(second: 25), subtitles.cues[3].endTime)
		XCTAssertEqual("et dolore magna aliqua", subtitles.cues[3].text)

		XCTAssertEqual(Subtitles.Time(second: 18), subtitles.cues[4].startTime)
		XCTAssertEqual(Subtitles.Time(second: 29), subtitles.cues[4].endTime)
		XCTAssertEqual("Ut enim ad minim veniam quis, nostrud", subtitles.cues[4].text)
	}

	func testBasic2() throws {
		let fileURL = try resourceURL(forResource: "sample2", withExtension: "ttml")
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(5, subtitles.cues.count)

		XCTAssertEqual("It seems a paradox, does it not,", subtitles.cues[0].text)
		XCTAssertEqual("that the image formed on\nthe Retina should be inverted?", subtitles.cues[1].text)
		XCTAssertEqual("It is puzzling, why is it\nwe do not see things upside-down?", subtitles.cues[2].text)
		XCTAssertEqual("You have never heard the Theory,\nthen, that the Brain also is inverted?", subtitles.cues[3].text)
		XCTAssertEqual("No indeed! What a beautiful fact!", subtitles.cues[4].text)
	}

	func testBasic3() throws {
		let fileURL = try resourceURL(forResource: "sample3", withExtension: "ttml")
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(9, subtitles.cues.count)

		XCTAssertEqual(Subtitles.Time(second: 1), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(second: 3), subtitles.cues[0].endTime)
		XCTAssertEqual("Disons que vous voulez multiplier 12 x 13", subtitles.cues[0].text)

		XCTAssertEqual(Subtitles.Time(second: 42), subtitles.cues[8].startTime)
		XCTAssertEqual(Subtitles.Time(second: 44), subtitles.cues[8].endTime)
		XCTAssertEqual("Et ce est la anser - 156", subtitles.cues[8].text)
	}

	func testPirates() throws {
		let fileURL = try resourceURL(forResource: "pirates", withExtension: "ttml")
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(1283, subtitles.cues.count)

		XCTAssertEqual(Subtitles.Time(second: 21, millisecond: 888), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(second: 24, millisecond: 686), subtitles.cues[0].endTime)
		XCTAssertEqual("I don't want you to think\nof this as just a film...", subtitles.cues[0].text)

		XCTAssertEqual(Subtitles.Time(second: 24, millisecond: 858), subtitles.cues[1].startTime)
		XCTAssertEqual(Subtitles.Time(second: 28, millisecond: 294), subtitles.cues[1].endTime)
		XCTAssertEqual("...some process of converting\nelectrons and magnetic impulses...", subtitles.cues[1].text)

		XCTAssertEqual(Subtitles.Time(timeInSeconds: 5672.633), subtitles.cues[1280].startTime)
		XCTAssertEqual(Subtitles.Time(timeInSeconds: 5676.399), subtitles.cues[1280].endTime)
		XCTAssertEqual("I think it's gonna be really interesting,\nI mean, you and me together.", subtitles.cues[1280].text)
	}
}
