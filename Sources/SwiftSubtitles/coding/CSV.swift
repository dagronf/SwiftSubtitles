//
//  CSV.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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
import TinyCSV

extension Subtitles.Coder {
	/// A basic CSV coder
	///
	/// UTI: public.comma-separated-values-text
	/// Mime-type: text/csv
	public struct CSV: SubtitlesCodable, SubtitlesTextCodable {
		public static var extn: String { "csv" }
		public static func Create() -> Self { CSV() }
		public init() { }
	}
}

// https://www.rfc-editor.org/rfc/rfc4180.html

public extension Subtitles.Coder.CSV {
	/// Encode subtitles as Data
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	///   - encoding: The encoding to use if the content is text
	/// - Returns: The encoded Data
	func encode(subtitles: Subtitles, encoding: String.Encoding) throws -> Data {
		let str = try self.encode(subtitles: subtitles)
		guard let data = str.data(using: encoding) else {
			throw SubTitlesError.invalidEncoding
		}
		return data
	}

	/// Encode subtitles as a String
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	/// - Returns: The encoded String
	func encode(subtitles: Subtitles) throws -> String {
		var results: [[String]] = []
		results.append(["No.","Timecode In","Timecode Out","Subtitle"])
		for cue in subtitles.cues.enumerated() {
			var row: [String] = []

			// Add the position
			row.append("\(cue.offset + 1)")

			// Add the start time
			let start = cue.element.startTime
			let startS = String(format: "%02d:%02d:%02d:%03d", start.hour, start.minute, start.second, start.millisecond)
			row.append(startS)

			// Add the end time
			let end = cue.element.endTime
			let endS = String(format: "%02d:%02d:%02d:%03d", end.hour, end.minute, end.second, end.millisecond)
			row.append(endS)

			// Add the text
			row.append(cue.element.text)

			results.append(row)
		}
		return TinyCSV.Coder().encode(csvdata: results, delimiter: .comma)
	}
}

public extension Subtitles.Coder.CSV {
	/// Decode subtitles from json data
	/// - Parameters:
	///   - data: The data to decode
	///   - encoding: The string encoding for the data content
	/// - Returns: Subtitles
	func decode(_ data: Data, encoding: String.Encoding) throws -> Subtitles {
		guard let str = String(data: data, encoding: encoding) else {
			throw SubTitlesError.invalidEncoding
		}
		return try self.decode(str)
	}

	/// Decode subtitles from a json string
	/// - Parameters:
	///   - content: The string
	/// - Returns: Subtitles
	func decode(_ content: String) throws -> Subtitles {
		// "No.,Timecode In,Timecode Out,Subtitle"
		let csv = TinyCSV.Coder().decode(text: content)
		var cues: [Subtitles.Cue] = []

		for row in csv.records {
			if row.count < 4 {
				// Skip?
				continue
			}

			// Index
			let indexS = row[0]
			guard let index = Int(indexS) else {
				// Skip?
				continue
			}

			// Start time
			guard let startTime = try? parseTime(index: 0, timeString: row[1]) else {
				// Skip?
				continue
			}

			// End time
			guard let endTime = try? parseTime(index: 0, timeString: row[2]) else {
				// Skip?
				continue
			}

			let text = row[3]

			cues.append(
				Subtitles.Cue(
					position: index,
					startTime: startTime,
					endTime: endTime,
					text: text
				)
			)
		}
		return Subtitles(cues)
	}
}

private extension Subtitles.Coder.CSV {
	// h m s ms
	//  00:00:00[.,:]000
	static let CSVTimeFormat__ = try! DSFRegex(#"^(\d+):(\d{1,2}):(\d{1,2})[,\.:](\d{3})$"#)
	static let CSVTimeFormatTens__ = try! DSFRegex(#"^(\d+):(\d{1,2}):(\d{1,2})[,\.:](\d{2})$"#)

	func parseTime(index: Int, timeString: String) throws -> Subtitles.Time {

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
