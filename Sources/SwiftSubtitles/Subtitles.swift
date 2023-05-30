//
//  Subtitles.swift
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

/// An Subtitles file representation
public struct Subtitles: Equatable, Codable {
	/// Subtitle cues
	public let cues: [Cue]

	/// Create using an array of subtitle cues
	public init(_ cues: [Cue]) {
		self.cues = cues.sorted { a, b in a.startTime < b.startTime }
	}

	/// Return the first cue containing the seconds value
	@inlinable public func firstCue(containing secondsValue: Double) -> Cue? {
		self.cues.first { $0.contains(secondsValue: secondsValue) }
	}
}

public extension Subtitles {
	/// Return the first cue containing the seconds value
	@inlinable func firstCue(containing time: Time) -> Cue? {
		self.firstCue(containing: time.timeInSeconds)
	}

	/// Locate the cue that either contains the time value, or is the _next_ cue after the time value
	func nextCueIndex(for secondsValue: Double) -> Int? {
		guard let first = self.cues.first else { return nil }
		if first.startTime.timeInSeconds > secondsValue {
			return 0
		}

		// Check if we are before the first cue
		if first.startTime.timeInSeconds > secondsValue {
			return 0
		}

		for index in (0 ..< self.cues.count - 1) {
			let curr = self.cues[index]
			let next = self.cues[index + 1]

			if secondsValue > curr.endTime.timeInSeconds && secondsValue < next.startTime.timeInSeconds {
				return index + 1
			}
		}
		return nil
	}

	struct CueTypeResult {
		/// Is the time inside an existing cue?
		let isInCue: Bool
		/// If we're inside a cue, the index of the cue. If not, the index of the _next_ cue
		let cueIndex: Int
	}

	func cueType(for secondsValue: Double) -> CueTypeResult? {
		if let c = self.cues.enumerated().first(where: { $0.element.contains(secondsValue: secondsValue) }) {
			return CueTypeResult(isInCue: true, cueIndex: c.offset)
		}
		if let c = self.nextCueIndex(for: secondsValue) {
			return CueTypeResult(isInCue: false, cueIndex: c)
		}
		return nil
	}
}

// MARK: - Decoding

public extension Subtitles {
	/// Create an subtitles object using the contents of a file
	init(fileURL: URL, encoding: String.Encoding) throws {
		guard let coder = Subtitles.Coder.coder(fileExtension: fileURL.pathExtension) else {
			throw SubTitlesError.unsupportedFileType(fileURL.pathExtension)
		}

		do {
			if let coder = coder as? SubtitlesTextCodable {
				var usedEncoding: String.Encoding = .ascii
				let s = try String(contentsOf: fileURL, usedEncoding: &usedEncoding)
				self = try coder.decode(s)
				return
			}
		}
		catch {
			// Fall back to trying the binary coder
		}

		self = try coder.decode(fileURL: fileURL, encoding: encoding)
	}

	/// Create an subtitles object from the content of a string
	/// - Parameters:
	///   - content: The string containing the subtitle content
	///   - expectedExtension: The expected format for the content expressed as the subtitle format's file extension.
	init(content: String, expectedExtension: String) throws {
		guard let coder = Subtitles.Coder.coder(fileExtension: expectedExtension) else {
			throw SubTitlesError.unsupportedFileType(expectedExtension)
		}

		guard let coder = coder as? SubtitlesTextCodable else {
			throw SubTitlesError.coderGeneratesBinaryContent
		}

		self = try coder.decode(content)
	}

	/// Create an subtitles object from the content of a Data
	/// - Parameters:
	///   - data: The data containing the subtitle content
	///   - expectedExtension: The expected format for the content expressed as the subtitle format's file extension.
	///   - encoding: The expected text encoding for the content
	init(data: Data, expectedExtension: String, encoding: String.Encoding) throws {
		guard let coder = Subtitles.Coder.coder(fileExtension: expectedExtension) else {
			throw SubTitlesError.unsupportedFileType(expectedExtension)
		}
		self = try coder.decode(data, encoding: encoding)
	}
}

// MARK: - Encoding

public extension Subtitles {
	/// Encode subtitles into a string with the format matching the specified file extension
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	///   - fileExtension: The extension of subtitle file to generate
	static func encode(_ subtitles: Subtitles, fileExtension: String) throws -> String {
		guard let coder = Subtitles.Coder.coder(fileExtension: fileExtension) else {
			throw SubTitlesError.unsupportedFileType(fileExtension)
		}
		guard let coder = coder as? SubtitlesTextCodable else {
			throw SubTitlesError.coderGeneratesBinaryContent
		}
		return try coder.encode(subtitles: subtitles)
	}

	/// Encode subtitles into a data object with the format matching the specified file extension
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	///   - fileExtension: The type of subtitles to write
	///   - encoding: If the coder supports it, the string encoding
	/// - Returns: Data
	static func encode(_ subtitles: Subtitles, fileExtension: String, encoding: String.Encoding) throws -> Data {
		guard let coder = Subtitles.Coder.coder(fileExtension: fileExtension) else {
			throw SubTitlesError.unsupportedFileType(fileExtension)
		}
		return try coder.encode(subtitles: subtitles, encoding: encoding)
	}

	/// Encode the cues into a string with the format matching the specified file extension
	/// - Parameters:
	///   - fileExtension: The extension of subtitle file to generate
	@inlinable func encode(fileExtension: String) throws -> String {
		try Self.encode(self, fileExtension: fileExtension)
	}

	/// Encode the SRT cues as a Data object
	/// - Parameters:
	///   - fileExtension: The extension of subtitle file to generate
	///   - encoding: The text encoding for the string
	/// - Returns: The generated subtitles file as raw data
	func encode(fileExtension: String, encoding: String.Encoding) throws -> Data {
		guard let coder = Subtitles.Coder.coder(fileExtension: fileExtension) else {
			throw SubTitlesError.unsupportedFileType(fileExtension)
		}
		return try coder.encode(subtitles: self, encoding: encoding)
	}
}

// MARK: - Sorting

public extension Subtitles {
	/// Return a new subtitles object with the entries sorted by the position
	var positionSorted: Subtitles {
		let entries = self.cues.sorted { a, b in a.position ?? 0 < b.position ?? 0 }
		return Subtitles(entries)
	}

	/// Return a new subtitles object with the entries sorted by start time of each entry
	var startTimeSorted: Subtitles {
		let entries = self.cues.sorted { a, b in a.startTime < b.startTime }
		return Subtitles(entries)
	}
}
