import XCTest
@testable import SwiftSubtitles

final class VTTTests: XCTestCase {
	func testExample() throws {
		let fileURL = Bundle.module.url(forResource: "sample", withExtension: "vtt")!
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)
		XCTAssertEqual(3, subtitles.cues.count)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 2, second: 15, millisecond: 0), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 2, second: 20, millisecond: 0), subtitles.cues[0].endTime)
		XCTAssertEqual("- Ta en kopp varmt te.\n- Det är inte varmt.", subtitles.cues[0].text)

		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 2, second: 25, millisecond: 0), subtitles.cues[2].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 2, second: 30, millisecond: 0), subtitles.cues[2].endTime)
		XCTAssertEqual("3 This is the third chapter", subtitles.cues[2].identifier)
		XCTAssertEqual("- Ta en kopp", subtitles.cues[2].text)

		let coder = Subtitles.Coder.VTT()
		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)
		XCTAssertEqual(3, decoded.cues.count)

		XCTAssertEqual(subtitles, decoded)
	}

	func testDecode() throws {
		let vtt = """
WEBVTT

00:01.000 --> 00:04.000
- Never drink liquid nitrogen.

00:05.000 --> 00:09.000
- It will perforate your stomach.
- You could die.
"""
		let coder = Subtitles.Coder.VTT()
		let subtitles = try coder.decode(vtt)
		XCTAssertEqual(2, subtitles.cues.count)
		XCTAssertEqual("- Never drink liquid nitrogen.", subtitles.cues[0].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 1, millisecond: 0), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 0), subtitles.cues[0].endTime)

		XCTAssertEqual("- It will perforate your stomach.\n- You could die.", subtitles.cues[1].text)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 5, millisecond: 0), subtitles.cues[1].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 9, millisecond: 0), subtitles.cues[1].endTime)

		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)
		XCTAssertEqual(2, decoded.cues.count)

		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 1, millisecond: 0), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 0), subtitles.cues[0].endTime)
		XCTAssertEqual("- Never drink liquid nitrogen.", decoded.cues[0].text)

		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 5, millisecond: 0), subtitles.cues[1].startTime)
		XCTAssertEqual(Subtitles.Time(hour: 0, minute: 0, second: 9, millisecond: 0), subtitles.cues[1].endTime)
		XCTAssertEqual("- It will perforate your stomach.\n- You could die.", decoded.cues[1].text)
	}

	func testMicrosoftTests() throws {
		// https://support.microsoft.com/en-us/office/create-closed-captions-for-a-video-b1cfb30f-5b00-4435-beeb-2a25e115024b
		let content = """
WEBVTT

00:00:01.000 --> 00:00:05.330
Good day everyone, my name is June Doe.

00:00:07.608 --> 00:00:15.290
This video teaches you how to
build a sandcastle on any beach.
"""

		let coder = Subtitles.Coder.VTT()
		let subtitles = try coder.decode(content)
		XCTAssertEqual(2, subtitles.cues.count)
		XCTAssertEqual(Subtitles.Time(second: 1, millisecond: 0), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(second: 5, millisecond: 330), subtitles.cues[0].endTime)
		XCTAssertEqual("Good day everyone, my name is June Doe.", subtitles.cues[0].text)
		XCTAssertEqual(Subtitles.Time(second: 7, millisecond: 608), subtitles.cues[1].startTime)
		XCTAssertEqual(Subtitles.Time(second: 15, millisecond: 290), subtitles.cues[1].endTime)
		XCTAssertEqual("This video teaches you how to\nbuild a sandcastle on any beach.", subtitles.cues[1].text)

		// Round trip
		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)
		XCTAssertEqual(2, decoded.cues.count)
		XCTAssertEqual(subtitles, decoded)
	}

	func testW3Example() throws {
		let content = """
WEBVTT

00:11.000 --> 00:13.000
<v Roger Bingham>We are in New York City

00:13.000 --> 00:16.000
<v Roger Bingham>We’re actually at the Lucern Hotel, just down the street

00:16.000 --> 00:18.000
<v Roger Bingham>from the American Museum of Natural History

00:18.000 --> 00:20.000
<v Roger Bingham>And with me is Neil deGrasse Tyson

00:20.000 --> 00:22.000
<v Roger Bingham>Astrophysicist, Director of the Hayden Planetarium

00:22.000 --> 00:24.000
<v Roger Bingham>at the AMNH.

00:24.000 --> 00:26.000
<v Roger Bingham>Thank you for walking down here.

00:27.000 --> 00:30.000
<v Roger Bingham>And I want to do a follow-up on the last conversation we did.

00:30.000 --> 00:31.500 align:right size:50%
<v Roger Bingham>When we e-mailed—

00:30.500 --> 00:32.500 align:left size:50%
<v Neil deGrasse Tyson>Didn’t we talk about enough in that conversation?

00:32.000 --> 00:35.500 align:right size:50%
<v Roger Bingham>No! No no no no; 'cos 'cos obviously 'cos

00:32.500 --> 00:33.500 align:left size:50%
<v Neil deGrasse Tyson><i>Laughs</i>

00:35.500 --> 00:38.000
<v Roger Bingham>You know I’m so excited my glasses are falling off here.
"""
		let coder = Subtitles.Coder.VTT()
		let subtitles = try coder.decode(content)
		XCTAssertEqual(13, subtitles.cues.count)
		XCTAssertEqual(Subtitles.Time(second: 11, millisecond: 0), subtitles.cues[0].startTime)
		XCTAssertEqual(Subtitles.Time(second: 13, millisecond: 0), subtitles.cues[0].endTime)
		XCTAssertEqual("<v Roger Bingham>We are in New York City", subtitles.cues[0].text)
	}

	func testMoreComplex() throws {
		let content = """
WEBVTT

STYLE
::cue {
  background-image: linear-gradient(to bottom, dimgray, lightgray);
  color: papayawhip;
}
/* Style blocks cannot use blank lines nor "dash dash greater than" */

NOTE comment blocks can be used between style blocks.

STYLE
::cue(b) {
  color: peachpuff;
}

hello
00:00:00.000 --> 00:00:10.000
Hello <b>world</b>.

NOTE style blocks cannot appear after the first cue.
"""

		let coder = Subtitles.Coder.VTT()
		let subtitles = try coder.decode(content)
		XCTAssertEqual(1, subtitles.cues.count)
		XCTAssertEqual(subtitles.cues[0].startTime, Subtitles.Time())
		XCTAssertEqual(subtitles.cues[0].endTime, Subtitles.Time(second: 10))
		XCTAssertEqual(subtitles.cues[0].text, "Hello <b>world</b>.")

		// Round trip
		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)
		XCTAssertEqual(1, decoded.cues.count)
		XCTAssertEqual(subtitles, decoded)
	}

	func testW3Further() throws {
		let content = """
WEBVTT

test
00:00.000 --> 00:02.000
This is a test.

123
00:00.000 --> 00:02.000
That’s an, an, that’s an L!

crédit de transcription
3:00:04.000 --> 5:00:05.000
Transcrit par Célestes™
"""
		let coder = Subtitles.Coder.VTT()
		let subtitles = try coder.decode(content)
		XCTAssertEqual(3, subtitles.cues.count)

		XCTAssertEqual(subtitles.cues[2].startTime, Subtitles.Time(hour: 3, second: 4))
		XCTAssertEqual(subtitles.cues[2].endTime, Subtitles.Time(hour: 5, second: 5))
		XCTAssertEqual(subtitles.cues[2].identifier, "crédit de transcription")
		XCTAssertEqual(subtitles.cues[2].text, "Transcrit par Célestes™")

		// Round trip
		let encoded = try coder.encode(subtitles: subtitles)
		let decoded = try coder.decode(encoded)
		XCTAssertEqual(3, decoded.cues.count)
		XCTAssertEqual(subtitles, decoded)
	}

	func testAnotherExample() throws {
		// https://clideo.com/resources/subtitle-file-formats-overview
		let content = """
WEBVTT
Kind: captions
Language: en

00:09.000 --> 00:11.000
1st subtitle.

00:11.000 --> 00:13.000
2nd subtitle.
"""
		let coder = Subtitles.Coder.VTT()
		let subtitles = try coder.decode(content)
		XCTAssertEqual(2, subtitles.cues.count)

		XCTAssertEqual(subtitles.cues[0].startTime, Subtitles.Time(second: 9))
		XCTAssertEqual(subtitles.cues[0].endTime, Subtitles.Time(second: 11))
		XCTAssertNil(subtitles.cues[0].identifier)
		XCTAssertEqual(subtitles.cues[0].text, "1st subtitle.")

		XCTAssertEqual(subtitles.cues[1].startTime, Subtitles.Time(second: 11))
		XCTAssertEqual(subtitles.cues[1].endTime, Subtitles.Time(second: 13))
		XCTAssertNil(subtitles.cues[1].identifier)
		XCTAssertEqual(subtitles.cues[1].text, "2nd subtitle.")
	}

    func testCommaDecimalHandling() throws {
        let contentWithCommas = """
WEBVTT

00:00:01,000 --> 00:00:04,000
Never drink liquid nitrogen.
"""

        let coder = Subtitles.Coder.VTT()
        let subtitlesWithCommas = try coder.decode(contentWithCommas)

        XCTAssertEqual(subtitlesWithCommas.cues[0].startTime, Subtitles.Time(hour: 0, minute: 0, second: 1, millisecond: 0))
        XCTAssertEqual(subtitlesWithCommas.cues[0].endTime, Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 0))
    }

    func testDotDecimalHandling() throws {
        let contentWithDots = """
WEBVTT

00:00:01.000 --> 00:00:04.000
Never drink liquid nitrogen.
"""

        let coder = Subtitles.Coder.VTT()
        let subtitlesWithDots = try coder.decode(contentWithDots)

        XCTAssertEqual(subtitlesWithDots.cues[0].startTime, Subtitles.Time(hour: 0, minute: 0, second: 1, millisecond: 0))
        XCTAssertEqual(subtitlesWithDots.cues[0].endTime, Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 0))
    }

    func testSpaceHandling() throws {
        // Test with spaces around '-->'
        let contentWithSpaces = """
WEBVTT

00:00:01.000  -->  00:00:04.000
Never drink liquid nitrogen.
"""
        let coder = Subtitles.Coder.VTT()
        var subtitles = try coder.decode(contentWithSpaces)

        XCTAssertEqual(subtitles.cues[0].startTime, Subtitles.Time(hour: 0, minute: 0, second: 1, millisecond: 0))
        XCTAssertEqual(subtitles.cues[0].endTime, Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 0))

        // Test without spaces around '-->'
        let contentWithoutSpaces = """
WEBVTT

00:00:01.000-->00:00:04.000
Never drink liquid nitrogen.
"""
        subtitles = try coder.decode(contentWithoutSpaces)

        XCTAssertEqual(subtitles.cues[0].startTime, Subtitles.Time(hour: 0, minute: 0, second: 1, millisecond: 0))
        XCTAssertEqual(subtitles.cues[0].endTime, Subtitles.Time(hour: 0, minute: 0, second: 4, millisecond: 0))
    }
}
