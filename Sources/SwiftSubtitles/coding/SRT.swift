//
//  SRT.swift
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

import DSFRegex
import Foundation

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11.0, iOS 14, tvOS 14, watchOS 7, *)
extension UTType {
	public static var srt: UTType {
		UTType(importedAs: "public.srt", conformingTo: .plainText)
	}
}
#endif

extension Subtitles.Coder {
	/// SRT (SubRip) decoder/encoder
	public struct SRT: SubtitlesCodable, SubtitlesTextCodable {
		public static var extn: String { "srt" }
		public static func Create() -> Self { SRT() }
		public init() { }
	}
}

/// Regex for matching an SRT time string
private let SRTTimeRegex__ = try! DSFRegex(#"(\d+):(\d{1,2}):(\d{1,2}),(\d{3})\s-->\s(\d+):(\d{2}):(\d{1,2}),(\d{3})"#)

public extension Subtitles.Coder.SRT {
	/// Encode subtitles as Data
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	///   - encoding: The encoding to use if the content is text
	/// - Returns: The encoded Data
	func encode(subtitles: Subtitles, encoding: String.Encoding) throws -> Data {
		let content = try self.encode(subtitles: subtitles)
		guard let data = content.data(using: encoding, allowLossyConversion: false) else {
			throw SubTitlesError.invalidEncoding
		}
		return data
	}

	/// Encode subtitles as a String
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	/// - Returns: The encoded String
	func encode(subtitles: Subtitles) throws -> String {
		var result = ""
		var position: Int = 0

		subtitles.cues.forEach { entry in
			if !result.isEmpty {
				result += "\n"
			}

			if let p = entry.position {
				position = p
			}
			else {
				position += 1
			}

			result += "\(position)\n"

			let s = entry.startTime
			let e = entry.endTime
			result += String(
				format: "%02d:%02d:%02d,%03d --> %02d:%02d:%02d,%03d\n",
				s.hour, s.minute, s.second, s.millisecond,
				e.hour, e.minute, e.second, e.millisecond
			)

			result += "\(entry.text)\n"
		}

		return result
	}
}

public extension Subtitles.Coder.SRT {
	/// Decode subtitles from srt data
	/// - Parameters:
	///   - data: The data to decode
	///   - encoding: The string encoding for the data content
	/// - Returns: Subtitles
	func decode(_ data: Data, encoding: String.Encoding) throws -> Subtitles {
		guard let content = String(data: data, encoding: encoding) else {
			throw SubTitlesError.invalidEncoding
		}
		return try self.decode(content)
	}

	/// Decode subtitles from a srt-coded string
	/// - Parameters:
	///   - content: The string
	/// - Returns: Subtitles
	func decode(_ content: String) throws -> Subtitles {

		enum LineState {
			case blank
			case position
			case time
			case text
		}

		var results = [Subtitles.Cue]()

		let lines = content.removingBOM().lines

		var currentState: LineState = .blank

		var position: Int = -1
		var start: Subtitles.Time?
		var end: Subtitles.Time?
		var text: String = ""

		try lines.enumerated().forEach { item in
			let line = item.element.trimmingCharacters(in: .whitespaces)

			if line.isEmpty {
				if currentState == .blank {
					// just another separating line
				}
				else if currentState == .text {
					guard let s = start, let e = end else {
						throw SubTitlesError.invalidFile
					}

					// Note that the text _may_ be empty (some SRT files online had empty text in cues)
					results.append(Subtitles.Cue(position: position, startTime: s, endTime: e, text: text))

					position = -1
					start = nil
					end = nil
					text = ""

					currentState = .blank
				}
				else {
					throw SubTitlesError.invalidFile
				}
			}
			else {
				// Line has content
				if currentState == .blank {
					// Should be the position
					guard let p = Int(line) else {
						throw SubTitlesError.invalidPosition(item.offset + 1)
					}
					position = p
					currentState = .position
				}
				else if currentState == .position {
					// Should be the start/end  "00:05:00,400 --> 00:05:15,300"
					let matches = SRTTimeRegex__.matches(for: line)
					guard matches.count == 1 else {
						throw SubTitlesError.invalidTime(item.offset)
					}

					let captures = matches[0].captures
					guard captures.count == 8 else {
						throw SubTitlesError.invalidTime(item.offset)
					}

					guard
						let s_hour = UInt(line[captures[0]]),
						let s_min = UInt(line[captures[1]]),
						let s_sec = UInt(line[captures[2]]),
						let s_ms = UInt(line[captures[3]]),

						let e_hour = UInt(line[captures[4]]),
						let e_min = UInt(line[captures[5]]),
						let e_sec = UInt(line[captures[6]]),
						let e_ms = UInt(line[captures[7]])
					else {
						throw SubTitlesError.invalidTime(item.offset)
					}

					let s = Subtitles.Time(hour: s_hour, minute: s_min, second: s_sec, millisecond: s_ms)
					let e = Subtitles.Time(hour: e_hour, minute: e_min, second: e_sec, millisecond: e_ms)

					guard s < e else {
						throw SubTitlesError.startTimeAfterEndTime(item.offset)
					}

					start = s
					end = e

					currentState = .text
				}
				else if currentState == .text {
					if text.isEmpty == false {
						text += "\n"
					}
					text += line
				}
			}
		}

		if position != -1 {
			guard let s = start, let e = end else {
				throw SubTitlesError.invalidTime(-1)
			}

			let entry = Subtitles.Cue(position: position, startTime: s, endTime: e, text: text)
			results.append(entry)
		}

		return Subtitles(results)
	}
}
