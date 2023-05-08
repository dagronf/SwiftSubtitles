import XCTest
@testable import SwiftSubtitles

final class CommonTests: XCTestCase {

	func testTimeSorting() throws {

		do {
			(0 ... 10000).forEach { _ in
				let h1  = UInt.random(in: 0 ..< 60)
				let m1  = UInt.random(in: 0 ..< 60)
				let s1  = UInt.random(in: 0 ..< 60)
				let ms1 = UInt.random(in: 0 ..< 1000)
				let h2  = UInt.random(in: 0 ..< 60)
				let m2  = UInt.random(in: 0 ..< 60)
				let s2  = UInt.random(in: 0 ..< 60)
				let ms2 = UInt.random(in: 0 ..< 1000)
				let t1 = Subtitles.Time(hour: h1, minute: m1, second: s1, millisecond: ms1)
				let i1 = t1.timeInterval
				let t2 = Subtitles.Time(hour: h2, minute: m2, second: s2, millisecond: ms2)
				let i2 = t2.timeInterval
				XCTAssertEqual(t1 < t2, i1 < i2)
			}
		}

		do {
			let e1 = Subtitles.Time(hour: 54, minute: 43, second: 42, millisecond: 402)
			let e2 = Subtitles.Time(hour: 26, minute: 32, second: 16, millisecond: 869)
			XCTAssertTrue(e2 < e1)
			XCTAssertLessThan(e2, e1)

			let e3 = Subtitles.Time(hour: 54, minute: 43, second: 42, millisecond: 402)
			XCTAssertEqual(e1, e3)
		}

		do {
			let e1 = Subtitles.Time(interval: 1)
			let e2 = Subtitles.Time(interval: 2)
			XCTAssertLessThan(e1, e2)
		}

		do {
			let e1 = Subtitles.Time(hour: 2, minute: 3, second: 10, millisecond: 500)
			let e2 = Subtitles.Time(hour: 1, minute: 3, second: 10, millisecond: 500)
			XCTAssertLessThan(e2, e1)

			let e3 = Subtitles.Time(hour: 1, minute: 3, second: 10, millisecond: 500)
			XCTAssertFalse(e2 < e3)
			XCTAssertFalse(e3 < e2)
			XCTAssertEqual(e2, e3)
		}

		do {
			let e1 = Subtitles.Time(minute: 3, second: 10, millisecond: 500)
			let e2 = Subtitles.Time(hour: 1, minute: 3, second: 10, millisecond: 500)
			XCTAssertTrue(e1 < e2)
		}
	}
}
