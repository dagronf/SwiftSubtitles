import XCTest
@testable import SwiftSRT

final class SwiftSRTTests: XCTestCase {
	func testExample() throws {

		let content = """
1
00:05:00,400 --> 00:05:15,300
This is an example of a subtitle.

2
00:05:16,400 --> 00:05:25,300
This is an example of
a subtitle - 2nd subtitle.
"""

		let srt = try SRT(content: content)
		XCTAssertEqual(2, srt.entries.count)
		XCTAssertEqual(srt.entries[0].text, "This is an example of a subtitle.")
		XCTAssertEqual(srt.entries[0].startTime, SRT.Time(minute: 5, millisecond: 400))
		XCTAssertEqual(srt.entries[0].startTime.timeInterval, 300.4, accuracy: 0.001)
		XCTAssertEqual(srt.entries[0].endTime, SRT.Time(minute: 5, second: 15, millisecond: 300))
		XCTAssertEqual(srt.entries[0].endTime.timeInterval, 315.3, accuracy: 0.001)

		XCTAssertEqual(srt.entries[1].text, "This is an example of\na subtitle - 2nd subtitle.")
		XCTAssertEqual(srt.entries[1].startTime.timeInterval, 316.4, accuracy: 0.001)
		XCTAssertEqual(srt.entries[1].endTime.timeInterval, 325.3, accuracy: 0.001)

		let encoded = srt.encode()
		XCTAssertFalse(encoded.isEmpty)
	}

	func testEncodeDoco() throws {
		let entry1 = SRT.Entry(
			position: 1,
			startTime: SRT.Time(minute: 10),
			endTime: SRT.Time(minute: 11),
			text: "점점 더 많아지는\n시민들의 성난 목소리로..."
		)

		let entry2 = SRT.Entry(
			position: 2,
			startTime: SRT.Time(minute: 13, second: 5),
			endTime: SRT.Time(minute: 15, second: 10, millisecond: 101),
			text: "Second entry"
		)

		let srt = SRT(entries: [entry1, entry2])
		let content = srt.encode()

		let decoded = try SRT(content: content)
		XCTAssertEqual(2, decoded.entries.count)
		XCTAssertEqual(decoded.entries[0], entry1)
		XCTAssertEqual(decoded.entries[1], entry2)
	}

	func testExample2() throws {

		let content = """
1
00:01:34,769 --> 00:01:36,168
FamÃ­lia Soprano

2
00:01:36,304 --> 00:01:37,737
Peso

3
00:01:50,117 --> 00:01:53,780
Ela Ã© danÃ§arina. Broadway,
shows de verÃ£o, essas coisas.

4
00:01:53,955 --> 00:01:56,924
Estava me dizendo que Ginny...
ela danÃ§ava, nÃ£o Ã©?

5
00:01:57,124 --> 00:01:59,922
Deu aula de balÃ© anos atrÃ¡s.

6
00:02:05,032 --> 00:02:08,195
- Quem Ã©?
- NinguÃ©m. Jersey.

7
00:02:08,369 --> 00:02:10,394
Do grupo de Ralph Cifaretto.

"""

		let srt = try SRT(content: content)
		XCTAssertEqual(7, srt.entries.count)
		XCTAssertEqual(srt.entries[0].startTime, SRT.Time(minute: 1, second: 34, millisecond: 769))
		XCTAssertEqual(srt.entries[0].text, "FamÃ­lia Soprano")
		XCTAssertEqual(srt.entries[4].text, "Deu aula de balÃ© anos atrÃ¡s.")
	}

	func testExample3() throws {
		let content = """
1
00:00:03,400 --> 00:00:06,177
In this lesson, we're going to
be talking about finance. And

2
00:00:06,177 --> 00:00:10,009
one of the most important aspects
of finance is interest.

3
00:00:10,009 --> 00:00:13,655
When I go to a bank or some
other lending institution
"""

		let srt = try SRT(content: content)
		XCTAssertEqual(3, srt.entries.count)
		XCTAssertEqual(srt.entries[0].startTime.timeInterval, 3.4, accuracy: 0.0001)
		XCTAssertEqual(srt.entries[0].endTime.timeInterval, 6.177, accuracy: 0.0001)
		XCTAssertEqual(srt.entries[0].text, "In this lesson, we're going to\nbe talking about finance. And")
		XCTAssertEqual(srt.entries[1].startTime.timeInterval, 6.177, accuracy: 0.0001)
		XCTAssertEqual(srt.entries[1].endTime.timeInterval, 10.009, accuracy: 0.0001)
		XCTAssertEqual(srt.entries[1].text, "one of the most important aspects\nof finance is interest.")
		XCTAssertEqual(srt.entries[2].startTime.timeInterval, 10.009, accuracy: 0.0001)
		XCTAssertEqual(srt.entries[2].endTime.timeInterval, 13.655, accuracy: 0.0001)
		XCTAssertEqual(srt.entries[2].text, "When I go to a bank or some\nother lending institution")
	}

	func testFile1() throws {
		let fileURL = Bundle.module.url(forResource: "Teenage+Mutant+Ninja+Turtles.1990.Blu-ray", withExtension: "srt")!
		let content = try SRT(fileURL: fileURL)
		XCTAssertEqual(1072, content.entries.count)

		let e = content.entries[1071]

//		200
//		00:14:29,840 --> 00:14:31,080
//		난 아직 볼일이 남았다고!
		let s1 = content.entries[199]
		XCTAssertEqual(s1.position, 200)
		XCTAssertEqual(s1.startTime.timeInterval, 869.84, accuracy: 0.0001)
		XCTAssertEqual(s1.endTime.timeInterval, 871.08, accuracy: 0.0001)
		XCTAssertEqual(s1.text, "난 아직 볼일이 남았다고!")

//		1072
//		01:27:46,720 --> 01:27:47,926
//		내가 좀 웃겼지!
		XCTAssertEqual(e.position, 1072)
		XCTAssertEqual(e.startTime.timeInterval, 5266.72, accuracy: 0.0001)
		XCTAssertEqual(e.endTime.timeInterval, 5267.926, accuracy: 0.0001)
		XCTAssertEqual(e.text, "내가 좀 웃겼지!")
	}

	func testFile2() throws {
		let fileURL = Bundle.module.url(forResource: "utf16-test", withExtension: "srt")!
		let content = try SRT(fileURL: fileURL)
		XCTAssertEqual(2, content.entries.count)

		// Check a non-utf8 encoded file
		XCTAssertEqual(content.entries[1].position, 1098)
		XCTAssertEqual(content.entries[1].text, "中文鍵盤/中文键盘")
	}

	func testBasicTimeError() throws {
		do {
			// Extra space after the position
			let content = """
1

00:05:00,400 --> 00:05:15,300
This is an example of a subtitle.
"""
			XCTAssertThrowsError(try SRT(content: content))
		}

		do {
			// Extra space after the time
			let content = """
1
00:05:00,400 --> 00:05:15,300

This is an example of a subtitle.
"""
			XCTAssertThrowsError(try SRT(content: content))
		}

		do {
			// Invalid start time
			let content = """
1
00:05:00 --> 00:05:15,300
This is an example of a subtitle.
"""
			XCTAssertThrowsError(try SRT(content: content))
		}

		do {
			// Invalid end time
			let content = """
1
00:05:00,400 --> 00:20,300
This is an example of a subtitle.
"""
			XCTAssertThrowsError(try SRT(content: content))
		}

		do {
			// Additional space in the text
			let content = """
1
00:05:00,400 --> 00:20:33,300
This is an example of a subtitle.

Fish and chips
"""
			XCTAssertThrowsError(try SRT(content: content))
		}
	}
}
