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
import TinyCSV

extension Subtitles.Coder {
	/// A basic CSV coder
	///
	/// UTI: public.comma-separated-values-text
	/// Mime-type: text/csv
	///
	/// By default, the CSV is assumed to have the format `position,startTime,endTime,text`
	/// however this can be configured in the constructor if required.
	///
	/// Detected Time formats :-
	/// * SBV style: `00:00:00.000`
	/// * SRT style: `00:00:00,000`
	/// * Common style: `00:00:00:000`
	/// * milliseconds: `102727`
	public struct CSV: SubtitlesCodable, SubtitlesTextCodable {
		/// The format's expected extension
		public static var extn: String { "csv" }
		/// Create a CSV parser with default parsing options
		public static func Create() -> Self { CSV() }

		/// Available fields for parsing/writing with the column title
		///
		/// The column title is only used for encoding (ignored during decoding)
		public enum Field {
			/// The cue's identifier
			case identifier(title: String)
			/// The cue's position
			case position(title: String)
			/// The start time
			case startTime(title: String)
			/// The start time (in seconds)
			case startTimeInSeconds(title: String)
			/// The end time
			case endTime(title: String)
			/// The end time (in seconds)
			case endTimeInSeconds(title: String)
			/// The duration (in seconds)
			case durationInSeconds(title: String)
			/// The speaker
			case speaker(title: String)
			/// The cue text
			case text(title: String)
		}

		/// Default expected field order
		public static let DefaultFields: [Field] = [
			.position(title: "No."),
			.startTime(title: "Timecode In"),
			.endTime(title: "Timecode Out"),
			.text(title: "Subtitle")
		]

		/// Create a CSV coder/decoder
		/// - Parameters:
		///   - fields: The fields and expected order within a row
		///   - delimiter: The delimiter to use, or nil for auto-detect (default comma) (decoding/encoding)
		///   - fieldEscapeCharacter: The field escape character (decoding)
		///   - commentCharacter: The comment character (decoding)
		///   - headerLineCount: The number of lines at the start of the text to ignore (decoding)
		///   - exportColumnHeaders: If true, write a column header row (encoding)
		public init(
			fields: [Field] = Subtitles.Coder.CSV.DefaultFields,
			delimiter: TinyCSV.Delimiter = .comma,
			fieldEscapeCharacter: Character? = nil,
			commentCharacter: Character? = nil,
			headerLineCount: UInt? = nil,
			exportColumnHeaders: Bool = true
		) {
			self.fields = fields
			self.delimiter = delimiter
			self.fieldEscapeCharacter = fieldEscapeCharacter
			self.commentCharacter = commentCharacter
			self.headerLineCount = headerLineCount
			self.exportColumnHeaders = exportColumnHeaders
		}

		private let fields: [Field]
		private let delimiter: TinyCSV.Delimiter
		private let fieldEscapeCharacter: Character?
		private let commentCharacter: Character?
		private let headerLineCount: UInt?
		private let exportColumnHeaders: Bool
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

		if self.exportColumnHeaders {
			let titles: [String] = fields.map {
				switch $0 {
				case .identifier(let title): return title
				case .position(let title): return title
				case .startTime(let title): return title
				case .startTimeInSeconds(let title): return title
				case .endTime(let title): return title
				case .endTimeInSeconds(let title): return title
				case .durationInSeconds(let title): return title
				case .speaker(let title): return title
				case .text(let title): return title
				}
			}
			results.append(titles)
		}

		for cue in subtitles.cues.enumerated() {
			var row: [String] = []

			for field in self.fields {
				switch field {
				case .identifier:
					row.append(cue.element.identifier ?? "")
				case .position:
					if let p = cue.element.position {
						row.append("\(p)")
					}
					else {
						row.append("")
					}
				case .startTime:
					let start = cue.element.startTime
					let startS = String(format: "%02d:%02d:%02d:%03d", start.hour, start.minute, start.second, start.millisecond)
					row.append(startS)
				case .endTime:
					let start = cue.element.endTime
					let startS = String(format: "%02d:%02d:%02d:%03d", start.hour, start.minute, start.second, start.millisecond)
					row.append(startS)
				case .durationInSeconds:
					row.append("\(cue.element.duration)")
				case .speaker:
					row.append(cue.element.speaker ?? "")
				case .text:
					row.append(cue.element.text)
				case .startTimeInSeconds:
					row.append("\(cue.element.startTimeInSeconds)")
				case .endTimeInSeconds:
					row.append("\(cue.element.endTimeInSeconds)")
				}
			}
			results.append(row)
		}
		return TinyCSV.Coder().encode(csvdata: results, delimiter: delimiter)
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

		parser.startDecoding(
			text: content,
			delimiter: self.delimiter,
			fieldEscapeCharacter: self.fieldEscapeCharacter,
			commentCharacter: commentCharacter,
			headerLineCount: headerLineCount,
			emitField: nil,
			emitRecord: { row, columns in
				var identifier: String?
				var position: Int?
				var speaker: String?
				var text: String = ""
				var startTime: Subtitles.Time?
				var endTime: Subtitles.Time?
				var duration: Double?

				for column in columns.enumerated() {
					if column.offset >= fields.count {
						// Ignore field
						continue
					}

					switch fields[column.offset] {
					case .identifier:
						identifier = column.element
					case .position:
						position = Int(column.element)
					case .startTime:
						if let s = try? TimeParsing.parseCommonTime(index: column.offset, timeString: column.element) {
							startTime = s
						}
					case .startTimeInSeconds:
						if let s = Double(column.element) {
							startTime = Subtitles.Time(timeInSeconds: s)
						}
					case .endTime:
						if let e = try? TimeParsing.parseCommonTime(index: column.offset, timeString: column.element) {
							endTime = e
						}
					case .endTimeInSeconds:
						if let e = Double(column.element) {
							endTime = Subtitles.Time(timeInSeconds: e)
						}
					case .durationInSeconds:
						duration = Double(column.element)
					case .speaker:
						speaker = column.element
					case .text:
						text = column.element
					}
				}

				let cue: Subtitles.Cue? = {
					if endTime == nil && duration == nil {
						// If no duration is specified, just make the end time equal to the start time
						endTime = startTime
					}

					if let s = startTime, let e = endTime {
						return Subtitles.Cue(
							identifier: identifier,
							position: position,
							startTime: s,
							endTime: e,
							text: text,
							speaker: speaker
						)
					}
					else if let s = startTime, let d = duration {
						return Subtitles.Cue(
							identifier: identifier,
							position: position,
							startTime: s,
							duration: d,
							text: text,
							speaker: speaker
						)
					}
					else {
						// Invalid start/end/duration time combo
						return nil
					}
				}()

				if let cue = cue {
					cues.append(cue)
				}
				return true
			}
		)

		return Subtitles(cues)
	}
}
