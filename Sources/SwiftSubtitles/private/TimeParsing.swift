//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import DSFRegex

public extension Subtitles.Time {
	/// Create a subtitle time from a common time format
	///
	/// Supported formats :-
	///
	///  12345  -> milliseconds
	///  h[h*]:m[m]:s[s](,|:|.){MM[M]}
	init?(timeString: String) {
		guard let c = try? TimeParsing.parseCommonTime(index: 0, timeString: timeString) else {
			return nil
		}
		self = c
	}
}

struct TimeParsing {
	static let CSVTimeFormat__ = try! DSFRegex(#"^(\d+):(\d{1,2}):(\d{1,2})[,\.:](\d{3})$"#)
	static let CSVTimeFormatTens__ = try! DSFRegex(#"^(\d+):(\d{1,2}):(\d{1,2})[,\.:](\d{2})$"#)

	/// Parse a time from a string.
	///
	/// Supported formats :-
	///
	///  12345  -> milliseconds
	///  h[h*]:m[m]:s[s][,:.]{MM[M]}
	///
	static func parseCommonTime(index: Int, timeString: String) throws -> Subtitles.Time {
		// If we can parse the string as an integer, assume it is milliseconds
		if let tm = Int(timeString) {
			return Subtitles.Time(timeInSeconds: Double(tm) / 1000.0)
		}

		var isMillisecondsInTens = false

		var matches = Self.CSVTimeFormat__.matches(for: timeString)
		if matches.matches.count == 0 {
			// See if we can parse with a 'tens' of milliseconds instead
			isMillisecondsInTens = true
			matches = Self.CSVTimeFormatTens__.matches(for: timeString)
		}

		guard matches.matches.count == 1 else {
			throw SubTitlesError.invalidTime(index)
		}
		let captures = matches[0].captures
		guard captures.count >= 4 else {
			throw SubTitlesError.invalidTime(index)
		}

		guard
			let s_hour = UInt(timeString[captures[0]]),
			let s_min = UInt(timeString[captures[1]]),
			let s_sec = UInt(timeString[captures[2]]),
			let s_ms = UInt(timeString[captures[3]])
		else {
			throw SubTitlesError.invalidTime(index)
		}

		let s_msActual = s_ms * (isMillisecondsInTens ? 10 : 1)

		return Subtitles.Time(hour: s_hour, minute: s_min, second: s_sec, millisecond: s_msActual)
	}
}
