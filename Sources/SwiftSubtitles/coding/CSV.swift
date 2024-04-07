//
//  CSV.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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
		/// Create a CSV parser with default parsing options
		public static func Create() -> Self { CSV() }

		/// Create a CSV coder/decoder
		/// - Parameters:
		///   - delimiter: The delimiter to use, or nil for auto-detect (default comma) (decoding/encoding)
		///   - fieldEscapeCharacter: The field escape character (decoding)
		///   - commentCharacter: The comment character (decoding)
		///   - headerLineCount: The number of lines at the start of the text to ignore (decoding)
		public init(
			delimiter: TinyCSV.Delimiter? = nil,
			fieldEscapeCharacter: Character? = nil,
			commentCharacter: Character? = nil,
			headerLineCount: UInt? = nil
		) {
			self.delimiter = delimiter
			self.fieldEscapeCharacter = fieldEscapeCharacter
			self.commentCharacter = commentCharacter
			self.headerLineCount = headerLineCount
		}

		private let delimiter: TinyCSV.Delimiter?
		private let fieldEscapeCharacter: Character?
		private let commentCharacter: Character?
		private let headerLineCount: UInt?
	}
}

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
		return TinyCSV.Coder().encode(csvdata: results, delimiter: delimiter ?? .comma)
	}
}

public extension Subtitles.Coder.CSV {
	/// Decode subtitles from csv data
	/// - Parameters:
	///   - data: The data to decode
	///   - encoding: The string encoding for the data content
	/// - Returns: Subtitles
	///
	/// **Expected Format**:
	///
	/// 	`Position,Timecode In,Timecode Out,Text`
	///
	///  Note that the titles in the header don't matter, just the row content
	func decode(_ data: Data, encoding: String.Encoding) throws -> Subtitles {
		guard let str = String(data: data, encoding: encoding) else {
			throw SubTitlesError.invalidEncoding
		}
		return try self.decode(str)
	}

	/// Decode subtitles from a csv string
	/// - Parameters:
	///   - content: The string
	/// - Returns: Subtitles
	///
	/// **Expected Format**:
	///
	/// 	`Position,Timecode In,Timecode Out,Text`
	///
	///  Note that the titles in the header don't matter, just the row content
	func decode(_ content: String) throws -> Subtitles {
		let parser = TinyCSV.Coder()
		var cues: [Subtitles.Cue] = []

		var warnings: [String] = []

		parser.startDecoding(
			text: content,
			delimiter: delimiter,
			fieldEscapeCharacter: fieldEscapeCharacter,
			commentCharacter: commentCharacter,
			headerLineCount: headerLineCount,
			emitField: nil,
			emitRecord: { row, columns in
				guard columns.count >= 4 else {
					warnings.append("ROW[\(row)]: Invalid number of cells")
					return true
				}

				guard let position = Int(columns[0]) else {
					warnings.append("ROW[\(row)]: Invalid position field '\(columns[0])'")
					return true
				}

				guard let startTime = try? parseTime(index: 0, timeString: columns[1]) else {
					warnings.append("ROW[\(row)],POSITION[\(position)]: Invalid start time '\(columns[1])'")
					return true
				}

				guard let endTime = try? parseTime(index: 0, timeString: columns[2]) else {
					warnings.append("ROW[\(row)],POSITION[\(position)]: Invalid end time '\(columns[2])'")
					return true
				}

				let text = columns[3]
				guard text.count > 0 else {
					warnings.append("ROW[\(row)],POSITION[\(position)]: Empty cue text")
					return true
				}

				cues.append(
					Subtitles.Cue(
						position: position,
						startTime: startTime,
						endTime: endTime,
						text: text
					)
				)
				return true
			}
		)

		if warnings.count > 0 {
			Swift.print(warnings.joined(separator: "\n"))
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
