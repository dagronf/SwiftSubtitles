//
//  VTT.swift
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

extension Subtitles.Coder {
	/// VTT (WebVTT) decoder/Encoder
	///
	/// * [Mozilla definition](https://developer.mozilla.org/en-US/docs/Web/API/WebVTT_API)
	/// * [W3 discussion](https://www.w3.org/TR/webvtt1/)
	public struct VTT: SubtitlesCodable, SubtitlesTextCodable {
		public static var extn: String { "vtt" }
		public static func Create() -> Self { VTT() }
		public init() { }
	}
}

/// The time matching regex
private let VTTTimeRegex__ = try! DSFRegex(#"(?:(\d*):)?(?:(\d*):)(\d*)[.,](\d{3})\s*-->\s*(?:(\d*):)?(?:(\d*):)(\d*)[.,](\d{3})"#)

public extension Subtitles.Coder.VTT {
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
		var result = "WEBVTT\n\n"

		subtitles.cues.forEach { entry in
			if let identifier = entry.identifier {
				result += "\(identifier)"
			}
			result += "\n"

			let s = entry.startTime
			let e = entry.endTime
			result += String(
				format: "%02d:%02d:%02d.%03d --> %02d:%02d:%02d.%03d\n",
				s.hour, s.minute, s.second, s.millisecond,
				e.hour, e.minute, e.second, e.millisecond
			)

			result += "\(entry.text)\n\n"
		}

		return result
	}
}

public extension Subtitles.Coder.VTT {
	/// Decode subtitles from webvtt data
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

	/// Decode subtitles from a webvtt-coded string
	/// - Parameters:
	///   - content: The string
	/// - Returns: Subtitles
	func decode(_ content: String) throws -> Subtitles {
		let lines = content
			.removingBOM()
			.lines
			.enumerated()
			.map { (offset: $0.offset, element: $0.element.trimmingCharacters(in: .whitespaces)) }

		guard lines[0].element.contains("WEBVTT") else {
			throw SubTitlesError.invalidFile
		}

		// Break up into sections
		var sections: [[(index: Int, line: String)]] = []

		var inSection = false
		var currentLines = [(index: Int, line: String)]()
		lines.forEach { item in
			let line = item.element.trimmingCharacters(in: .whitespaces)
			if line.isEmpty {
				if inSection == true {
					// End of section
					sections.append(currentLines)
					currentLines.removeAll()
					inSection = false
				}
				else {

				}
			}
			else {
				if inSection == false {
					inSection = true
					currentLines = [(item.offset, line)]
				}
				else {
					currentLines.append((item.offset, line))
				}
			}
		}

		if inSection {
			sections.append(currentLines)
		}

		func parseTime(index: Int, timeLine: String) throws -> (Subtitles.Time, Subtitles.Time) {
			let matches = VTTTimeRegex__.matches(for: timeLine)
			guard matches.matches.count == 1 else {
				throw SubTitlesError.invalidTime(index)
			}
			let captures = matches[0].captures
			guard captures.count == 8 else {
				throw SubTitlesError.invalidTime(index)
			}

			let s_hour = UInt(timeLine[captures[0]]) ?? 0
			let s_min = UInt(timeLine[captures[1]]) ?? 0

			let e_hour = UInt(timeLine[captures[4]]) ?? 0
			let e_min = UInt(timeLine[captures[5]]) ?? 0

			guard
				let s_sec = UInt(timeLine[captures[2]]),
				let s_ms = UInt(timeLine[captures[3]]),
				let e_sec = UInt(timeLine[captures[6]]),
				let e_ms = UInt(timeLine[captures[7]])
			else {
				throw SubTitlesError.invalidTime(index)
			}

			let s = Subtitles.Time(hour: s_hour, minute: s_min, second: s_sec, millisecond: s_ms)
			let e = Subtitles.Time(hour: e_hour, minute: e_min, second: e_sec, millisecond: e_ms)

			return (s, e)
		}

		var results = [Subtitles.Cue]()

		for section in sections {
			guard section.count > 0 else {
				throw SubTitlesError.invalidFile
			}

			var index = 0
			let line = section[index]

			if line.line.contains("WEBVTT") ||
				line.line.starts(with: "NOTE") ||
				line.line.starts(with: "STYLE") ||
				line.line.starts(with: "REGION")
			{
				// Ignore
				continue
			}

			var identifier: String?
			var times: (Subtitles.Time, Subtitles.Time)?

			// 1. Optional cue identifier (string?)
			let l1 = section[index]
			do {
				times = try parseTime(index: l1.index, timeLine: l1.line)
				index += 1
			}
			catch {
				// Might have a cue identifier? Just ignore this failure
			}

			if times == nil {
				// Assume its a cue identifier
				identifier = l1.line

				index += 1
				let l2 = section[index]
				times = try parseTime(index: l2.index, timeLine: l2.line)
				index += 1
			}

			// next is the text
			var text = ""
			// Skip to the next blank
			while index < section.count && section[index].line.isEmpty == false {
				if !text.isEmpty {
					text += "\n"
				}
				text += section[index].line
				index += 1
			}

			let entry = Subtitles.Cue(
				identifier: identifier,
				startTime: times!.0,
				endTime: times!.1,
				text: text
			)
			results.append(entry)
		}

		return Subtitles(results)
	}
}
