//
//  SUB.swift
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

public extension Subtitles.Coder {
	/// SUB (MicroDVD) decoder/encoder
	///
	/// * [Format discussion](https://en.wikipedia.org/wiki/MicroDVD)
	///
	/// SUB format timing is based on _frames_ rather than a time value. During decode, the coder converts
	/// the frame count to a time value using the provided frame rate.
	///
	/// eg. {0}{156} --> {0 / framerate}{156 / framerate} --> 00:00:00.000 00:00:06:500
	///
	/// If you need a custom frame rate
	struct SUB: SubtitlesCodable, SubtitlesTextCodable {
		public static var extn: String { "sub" }
		public static func Create() -> Self { SUB() }

		public init(framerate: Double = 24.0) {
			assert(framerate > 0.0)
			self.framerate = framerate
		}

		/// Expected frames per second during decoding
		public var framerate: Double
	}
}

public extension Subtitles.Coder.SUB {
	/// Encode subtitles as Data
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	///   - encoding: The encoding to use if the content is text
	/// - Returns: The encoded Data
	func encode(subtitles: Subtitles, encoding: String.Encoding) throws -> Data {
		throw SubTitlesError.coderDoesntSupportEncoding
	}

	/// Encode subtitles as a String
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	/// - Returns: The encoded String
	func encode(subtitles: Subtitles) throws -> String {
		throw SubTitlesError.coderDoesntSupportEncoding
	}
}

public extension Subtitles.Coder.SUB {
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

		/// {0}{25}{y:i}Hello!|{y:b}How are you?

		for line in lines {
			let line = line.trimmingCharacters(in: .whitespacesAndNewlines)
			if line.isEmpty {
				continue
			}

			var startTime: TimeInterval?
			var endTime: TimeInterval?

			var text: String = ""
			let components = line.components(separatedBy: "|")
			try components.enumerated().forEach { component in
				// Split the lines around the {}
				var items = self.bracketSplit(component.element)
				if component.offset == 0 {
					guard items.count > 2 else {
						throw SubTitlesError.invalidFile
					}
					// Expect the start frame and end frame
					startTime = (Double(items[0]) ?? 0) / self.framerate
					endTime = (Double(items[1]) ?? 0) / self.framerate
					items = [String](items.dropFirst(2))
				}

				if text.count > 0 { text += "\n" }

				// Just ignore all the middle stuff
				text += items.last ?? ""
			}

			guard let st = startTime, let en = endTime, text.count > 0 else {
				continue
			}

			let s = Subtitles.Cue(
				startTime: Subtitles.Time(timeInSeconds: st),
				endTime: Subtitles.Time(timeInSeconds: en),
				text: text
			)
			results.append(s)

			startTime = nil
			endTime = nil
			text = ""
		}

		return Subtitles(results)
	}
}

private extension Subtitles.Coder.SUB {
	func bracketSplit(_ line: String) -> [String] {
		var results = [String]()
		var current = ""
		for char in line {
			if char == "{" {
				// Just skip
			}
			else if char == "}" {
				if current.count > 0 {
					results.append(current)
				}
				current = ""
			}
			else {
				current.append(char)
			}
		}
		if current.count > 0 {
			results.append(current)
		}
		return results
	}
}
