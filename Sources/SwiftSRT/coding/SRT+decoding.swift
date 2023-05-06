//
//  SRT+decoding.swift
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

import DSFRegex
import Foundation

// The regex for matching the time string
//
// 00:01:34,769 --> 00:01:36,168
private let TimeRegex__ = try! DSFRegex(#"(\d{1,2}):(\d{1,2}):(\d{1,2}),(\d{3})\s-->\s(\d{1,2}):(\d{2}):(\d{1,2}),(\d{3})"#)

// MARK: - Parsing

internal extension SRT {
	private enum LineState {
		case blank
		case position
		case time
		case text
	}

	/// Parse the file at `fileURL`
	@usableFromInline
	mutating func decode(fileURL: URL) throws {
		var encoding: String.Encoding = .utf8
		let str = try String(contentsOf: fileURL, usedEncoding: &encoding)
		try self.decode(str)
	}

	/// Parse data with the specified encoding
	/// - Parameters:
	///   - data: The raw data to parse
	///   - encoding: The expected encoding of the string
	@usableFromInline
	mutating func decode(data: Data, encoding: String.Encoding) throws {
		guard let str = String(data: data, encoding: encoding) else {
			throw SRTError.invalidEncoding
		}
		try self.decode(str)
	}

	/// Parse the srt from a raw string
	@usableFromInline
	mutating func decode(_ content: String) throws {
		let lines = content.components(separatedBy: .newlines)
		try self.decode(lines)
	}

	/// Parse an SRT from an array of lines
	@usableFromInline
	mutating func decode(_ lines: [String]) throws {
		var currentState: LineState = .blank

		var position: Int = -1
		var start: Time?
		var end: Time?
		var text: String = ""

		try lines.enumerated().forEach { item in
			let line = item.element.trimmingCharacters(in: .whitespaces)

			if line.isEmpty {
				if currentState == .blank {
					// just another separating line
				}
				else if currentState == .text {
					guard let s = start, let e = end else {
						throw SRTError.invalidFile
					}

					// srt entry is complete
					entries.append(Entry(position: position, startTime: s, endTime: e, text: text))

					position = -1
					start = nil
					end = nil
					text = ""

					currentState = .blank
				}
				else {
					throw SRTError.invalidFile
				}
			}
			else {
				// Line has content
				if currentState == .blank {
					// Should be the position
					guard let p = Int(line) else {
						throw SRTError.invalidPosition(item.offset + 1)
					}
					position = p
					currentState = .position
				}
				else if currentState == .position {
					// Should be the start/end  "00:05:00,400 --> 00:05:15,300"
					let matches = TimeRegex__.matches(for: line)
					guard matches.count == 1 else {
						throw SRTError.invalidTime(item.offset)
					}

					let captures = matches[0].captures
					guard captures.count == 8 else {
						throw SRTError.invalidTime(item.offset)
					}

					guard
						let s_hour = Int(line[captures[0]]),
						let s_min = Int(line[captures[1]]),
						let s_sec = Int(line[captures[2]]),
						let s_ms = Int(line[captures[3]]),

							let e_hour = Int(line[captures[4]]),
						let e_min = Int(line[captures[5]]),
						let e_sec = Int(line[captures[6]]),
						let e_ms = Int(line[captures[7]])
					else {
						throw SRTError.invalidTime(item.offset)
					}

					let s = Time(hour: s_hour, minute: s_min, second: s_sec, millisecond: s_ms)
					let e = Time(hour: e_hour, minute: e_min, second: e_sec, millisecond: e_ms)

					guard s < e else {
						throw SRTError.startTimeAfterEndTime(item.offset)
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
				throw SRTError.invalidTime(-1)
			}

			let entry = Entry(position: position, startTime: s, endTime: e, text: text)
			self.entries.append(entry)
		}
	}
}
