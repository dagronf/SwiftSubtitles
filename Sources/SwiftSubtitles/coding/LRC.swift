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

// LRC decoding/encoding

//  https://en.wikipedia.org/wiki/LRC_(file_format)
//  https://web.archive.org/web/20130906202730/http://www.stepmania.com/wiki/Song_Lyrics_-_LRC_Format
//  https://www.lyricsify.com

import DSFRegex
import Foundation

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11.0, iOS 14, tvOS 14, watchOS 7, *)
extension UTType {
	public static var lrc: UTType {
		UTType(importedAs: "public.lrc", conformingTo: .plainText)
	}
}
#endif

extension Subtitles.Coder {
	/// LRC (Lyrics) decoder/encoder
	public struct LRC: SubtitlesCodable, SubtitlesTextCodable {
		/// Sub-second encoding format
		///
		/// The standard as per [Wikipedia](https://en.wikipedia.org/wiki/LRC_(file_format)) shows that the
		/// sub-second format is 'hundredths of a second'. HOWEVER - some lrc files show millisecond values.
		public enum TimeFormat: CaseIterable {
			/// [xx:yy.zz] Minutes, seconds, hundredths of a second
			case minutesSecondsHundredths
			/// [xx:yy.zzz] Minutes, seconds, milliseconds
			case minutesSecondsMilliseconds
		}

		/// file extension
		public static var extn: String { "lrc" }
		/// Create a default LRC coder
		public static func Create() -> Self { LRC() }

		/// The time format to use when encoding
		public let timeFormat: TimeFormat

		/// Create an LRC (lyric) encoder
		/// - Parameter timeFormat: The formatting to use for the time when encoding
		public init(timeFormat: TimeFormat = .minutesSecondsHundredths) {
			self.timeFormat = timeFormat
		}
	}
}

public extension Subtitles.Coder.LRC {
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
		let subtitles = subtitles.startTimeSorted

		try subtitles.cues.forEach { entry in
			let minutes = entry.startTime.hour * 60 + entry.startTime.minute

			if minutes > 99 {
				// Too big to fit into LRC format
				throw SubTitlesError.timeTooLargeToExport(entry)
			}

			let seconds = entry.startTime.second
			let subseconds: UInt
			switch self.timeFormat {
			case .minutesSecondsHundredths:
				subseconds = entry.startTime.millisecond / 10
				result += String(format: "[%02d:%02d.%02d]", minutes, seconds, subseconds)
			case .minutesSecondsMilliseconds:
				subseconds = entry.startTime.millisecond
				result += String(format: "[%02d:%02d.%03d]", minutes, seconds, subseconds)
			}

			result += "\(entry.text)\n"
		}
		return result
	}
}

/// Regex for matching an LRC time string
private let LRCTimeRegex__ = try! DSFRegex(#"\[(\d{2})\:(\d{2})\.(\d{2,3})\]+"#)

public extension Subtitles.Coder.LRC {
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

	/// Decode subtitles from an lrc-coded string
	/// - Parameters:
	///   - content: The string
	/// - Returns: Subtitles
	func decode(_ content: String) throws -> Subtitles {

		var results = [Subtitles.Cue]()

		let lines = content.removingBOM().lines

		for line in lines.enumerated() {
			let line = line.element.trimmingCharacters(in: .whitespaces)
			let matches = LRCTimeRegex__.matches(for: line)
			if matches.count == 0 {
				// Not recognised as a lyric line
				continue
			}

			var times: [Subtitles.Time] = []

			var lastIndex: String.Index?

			for index in 0 ..< matches.count {
				let captures = matches[index].captures
				guard captures.count == 3 else {
					throw SubTitlesError.invalidTime(index)
				}

				let minsRaw = UInt(line[captures[0]]) ?? 0
				let sec = UInt(line[captures[1]]) ?? 0

				let milliseconds: UInt = {
					let s = line[captures[2]]
					let v = UInt(s) ?? 0
					if s.count == 2 {
						// hundredths of a second
						return v * 10
					}
					return v
				}()

				// [xx:yy.zz[z]] is minutes, seconds, milliseconds or hundredths of a second
				// Minutes can be >= 60, so we need to convert to hour/min

				let hours = minsRaw / 60
				let mins = minsRaw % 60

				let s = Subtitles.Time(hour: hours, minute: mins, second: sec, millisecond: milliseconds)
				times.append(s)

				lastIndex = captures[2].upperBound
			}

			guard let lastIndex = lastIndex else {
				// No text?
				continue
			}

			let lyricPos = line.index(after: lastIndex)

			let lyric = String(line[lyricPos...])

			for time in times {
				let entry = Subtitles.Cue(startTime: time, endTime: time, text: lyric)
				results.append(entry)
			}
		}

		return Subtitles(results)
	}
}
