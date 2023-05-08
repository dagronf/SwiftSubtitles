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
public struct Subtitles: Equatable {
	/// The file extension for the file format
	public internal(set) var cues: [Cue] = []

	/// Create using an array of subtitle cues
	public init(_ cues: [Cue]) {
		self.cues = cues
	}
}

// MARK: - Decoding

public extension Subtitles {
	/// Create an SRT object using the contents of a file
	init(fileURL: URL) throws {
		guard let coder = Subtitles.Coder.coder(fileExtension: fileURL.pathExtension) else {
			throw Subtitles.SRTError.unsupportedFileType(fileURL.pathExtension)
		}

		var encoding: String.Encoding = .utf8
		let content = try String(contentsOf: fileURL, usedEncoding: &encoding)

		self = try coder.decode(content)
	}

	/// Create an SRT object from the content of a string
	init(content: String, expectedExtension: String) throws {
		guard let coder = Subtitles.Coder.coder(fileExtension: expectedExtension) else {
			throw Subtitles.SRTError.unsupportedFileType(expectedExtension)
		}
		self = try coder.decode(content)
	}

	/// Create an SRT object from the content of a Data
	init(data: Data, expectedExtension: String, encoding: String.Encoding = .utf8) throws {
		guard let coder = Subtitles.Coder.coder(fileExtension: expectedExtension) else {
			throw Subtitles.SRTError.unsupportedFileType(expectedExtension)
		}
		guard let content = String(data: data, encoding: encoding) else {
			throw SRTError.invalidEncoding
		}
		self = try coder.decode(content)
	}
}

// MARK: - Encoding

public extension Subtitles {
	/// Encode subtitles into a string with the format matching the specified file extension
	/// - Parameters:
	///   - fileExtension: The extension of subtitle file to generate
	static func encode(fileExtension: String, subtitles: Subtitles) throws -> String {
		guard let coder = Subtitles.Coder.coder(fileExtension: fileExtension) else {
			throw Subtitles.SRTError.unsupportedFileType(fileExtension)
		}
		return try coder.encode(subtitles: subtitles)
	}

	/// Encode the cues into a string with the format matching the specified file extension
	/// - Parameters:
	///   - fileExtension: The extension of subtitle file to generate
	@inlinable func encode(fileExtension: String) throws -> String {
		try Self.encode(fileExtension: fileExtension, subtitles: self)
	}

	/// Encode the SRT cues as a Data object
	/// - Parameters:
	///   - fileExtension: The extension of subtitle file to generate
	///   - encoding: The text encoding for the string
	/// - Returns: The generated subtitles file as raw data
	func data(fileExtension: String, encoding: String.Encoding = .utf8) throws -> Data {
		guard let coder = Subtitles.Coder.coder(fileExtension: fileExtension) else {
			throw Subtitles.SRTError.unsupportedFileType(fileExtension)
		}
		let content = try coder.encode(subtitles: self)
		guard let data = content.data(using: encoding, allowLossyConversion: false) else {
			throw SRTError.invalidEncoding
		}
		return data
	}
}

// MARK: - Sorting

public extension Subtitles {
	/// Return a new SRT object with the entries sorted by the position
	var positionSorted: Subtitles {
		let entries = self.cues.sorted { a, b in a.position ?? 0 < b.position ?? 0 }
		return Subtitles(entries)
	}

	/// Return a new SRT object with the entries sorted by start time of each entry
	var startTimeSorted: Subtitles {
		let entries = self.cues.sorted { a, b in a.startTime < b.endTime }
		return Subtitles(entries)
	}
}
