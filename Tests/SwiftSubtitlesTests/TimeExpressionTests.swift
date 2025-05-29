import XCTest
@testable import SwiftSubtitles

final class TimeExpressionTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testClockTimes() throws {
		XCTAssertEqual(TimeExpression.parse("12:34:56"), .time(hours: 12, minutes: 34, seconds: 56))
		XCTAssertEqual(TimeExpression.parse("12:34:56.789"), .time(hours: 12, minutes: 34, seconds: 56, fraction: 789))
		XCTAssertEqual(TimeExpression.parse("01:02:03.003"), .time(hours: 1, minutes: 2, seconds: 3, fraction: 3))
		XCTAssertEqual(TimeExpression.parse("12:34:56:80"), .time(hours: 12, minutes: 34, seconds: 56, frames: 80))
		XCTAssertEqual(TimeExpression.parse("12:34:56:80.789"), .time(hours: 12, minutes: 34, seconds: 56, frames: 80, subFrames: 789))
	}

	func testClockAsStringValue() throws {
		XCTAssertEqual("12:34:56", TimeExpression.Clock(hours: 12, minutes: 34, seconds: 56).stringValue)
		XCTAssertEqual("00:01:00", TimeExpression.Clock(hours: 00, minutes: 1, seconds: 0).stringValue)
		XCTAssertEqual("12:34:56.789", TimeExpression.Clock(hours: 12, minutes: 34, seconds: 56, fraction: 789).stringValue)
		XCTAssertEqual("12:34:56:80", TimeExpression.Clock(hours: 12, minutes: 34, seconds: 56, frames: 80).stringValue)
		XCTAssertEqual("12:34:56:80.789", TimeExpression.Clock(hours: 12, minutes: 34, seconds: 56, frames: 80, subFrames: 789).stringValue)
	}

	func testClockComparison() throws {
		XCTAssertLessThan(
			TimeExpression.Clock(hours: 12, minutes: 11, seconds: 10),
			TimeExpression.Clock(hours: 12, minutes: 11, seconds: 11)
		)
	}

	func testDurationParsing() throws {
		XCTAssertEqual(TimeExpression.parse("12s"), .offsetTime(value: 12.0, metric: .seconds))
		XCTAssertEqual(TimeExpression.parse("86m"), .offsetTime(value: 86.0, metric: .minutes))
		XCTAssertEqual(TimeExpression.parse("5.5ms"), .offsetTime(value: 5.5, metric: .milliseconds))
		XCTAssertEqual(TimeExpression.parse("0.76s"), .offsetTime(value: 0.76, metric: .seconds))
	}

	func testOffsetAsStringValue() throws {
		XCTAssertEqual("12s", TimeExpression.Offset(value: 12.0, metric: .seconds).stringValue)
		XCTAssertEqual("86m", TimeExpression.Offset(value: 86, metric: .minutes).stringValue)
		XCTAssertEqual("5.5ms", TimeExpression.Offset(value: 5.5, metric: .milliseconds).stringValue)
		XCTAssertEqual("0.76h", TimeExpression.Offset(value: 0.76, metric: .hours).stringValue)
	}

	func testOffsetAsRawSeconds() throws {
		XCTAssertEqual(12.0, TimeExpression.Offset(value: 12.0, metric: .seconds).secondsValue)
		XCTAssertEqual(86 * 60, TimeExpression.Offset(value: 86, metric: .minutes).secondsValue)
		XCTAssertEqual(0.0055, TimeExpression.Offset(value: 5.5, metric: .milliseconds).secondsValue)
		XCTAssertEqual(2736, TimeExpression.Offset(value: 0.76, metric: .hours).secondsValue)
	}

	func testBasicEncode() throws {
		let fileURL = try resourceURL(forResource: "stby", withExtension: "csv")
		let subtitles = try Subtitles(fileURL: fileURL, encoding: .utf8)

		let result = try Subtitles.Coder.TTML().encode(subtitles: subtitles)
		XCTAssert(result.count > 0)
	}

}
