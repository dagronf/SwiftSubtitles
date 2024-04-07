//
//  SBV.swift
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
	/// SBV (SubViewer) decoder/encoder
	///
	/// * [Format discussion](https://support.google.com/youtube/answer/2734698?hl=en#zippy=%2Cbasic-file-formats%2Cadvanced-file-formats%2Csubviewer-sbv-example)
	public struct SBV: SubtitlesCodable, SubtitlesTextCodable {
		public static var extn: String { "sbv" }
		public static func Create() -> Self { SBV() }
		public init() { }
	}
}

/// Regex for matching an SBV time string
private let SBVTimeRegex__ = try! DSFRegex(#"^(\d+):(\d{1,2}):(\d{1,2})\.(\d{3}),(\d+):(\d{2}):(\d{1,2})\.(\d{3})$"#)


public extension Subtitles.Coder.SBV {
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

		try subtitles.cues.enumerated().forEach { item in
			let entry = item.element
			let s = entry.startTime
			let e = entry.endTime
			result += String(
				format: "%02d:%02d:%02d.%03d,%02d:%02d:%02d.%03d\n",
				s.hour, s.minute, s.second, s.millisecond,
				e.hour, e.minute, e.second, e.millisecond
			)

			if entry.text.isEmpty {
				throw SubTitlesError.missingText(item.offset)
			}

			result += "\(entry.text)\n\n"
		}

		return result
	}
}

public extension Subtitles.Coder.SBV {
	/// Decode subtitles from sbv data
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

	/// Decode subtitles from a sbv-coded string
	/// - Parameters:
	///   - content: The string
	/// - Returns: Subtitles
	func decode(_ content: String) throws -> Subtitles {
		var results = [Subtitles.Cue]()

		let lines = content.removingBOM().lines

		var position: Int = 1

		var index = 0
		while index < lines.count {
			// Skip blank lines
			while index < lines.count && lines[index].isEmpty {
				index += 1
			}

			if index == lines.count {
				break
			}

			let timeLine = lines[index]
			let matches = SBVTimeRegex__.matches(for: timeLine)
			guard matches.count == 1 else {
				throw SubTitlesError.invalidTime(index)
			}

			let captures = matches[0].captures
			guard captures.count == 8 else {
				throw SubTitlesError.invalidTime(index)
			}

			guard
				let s_hour = UInt(timeLine[captures[0]]),
				let s_min = UInt(timeLine[captures[1]]),
				let s_sec = UInt(timeLine[captures[2]]),
				let s_ms = UInt(timeLine[captures[3]]),

					let e_hour = UInt(timeLine[captures[4]]),
				let e_min = UInt(timeLine[captures[5]]),
				let e_sec = UInt(timeLine[captures[6]]),
				let e_ms = UInt(timeLine[captures[7]])
			else {
				throw SubTitlesError.invalidTime(index)
			}

			let s = Subtitles.Time(hour: s_hour, minute: s_min, second: s_sec, millisecond: s_ms)
			let e = Subtitles.Time(hour: e_hour, minute: e_min, second: e_sec, millisecond: e_ms)

			guard s < e else {
				throw SubTitlesError.startTimeAfterEndTime(index)
			}

			index += 1

			guard index < lines.count else {
				throw SubTitlesError.unexpectedEOF
			}

			// Text should be next
			var text = ""
			// Skip to the next blank
			while index < lines.count && lines[index].isEmpty == false {
				if !text.isEmpty { text += "\n" }
				text += lines[index]
				index += 1
			}

			if text.isEmpty {
				throw SubTitlesError.invalidTime(index)
			}

			let entry = Subtitles.Cue(position: position, startTime: s, endTime: e, text: text)
			results.append(entry)
			position += 1
		}
		return Subtitles(results)
	}
}


/*
 0:00:01.000,0:00:03.000
 Hello, and welcome to our video!

 0:00:04.000,0:00:06.000
 In this video, we will be discussing the SBV file format.

 0:00:07.000,0:00:10.000
 The SBV format is commonly used for storing subtitles for videos.
 */

/*
 0:00:00.599,0:00:04.160
 >> ALICE: Hi, my name is Alice Miller and this is John Brown

 0:00:04.160,0:00:06.770
 >> JOHN: and we're the owners of Miller Bakery.

 0:00:06.770,0:00:10.880
 >> ALICE: Today we'll be teaching you how to make
 our famous chocolate chip cookies!

 0:00:10.880,0:00:16.700
 [intro music]

 0:00:16.700,0:00:21.480
 Okay, so we have all the ingredients laid out here
 */
