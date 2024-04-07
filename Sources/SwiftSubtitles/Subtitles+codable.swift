//
//  Subtitles+codable.swift
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

/// Subtitles codable protocol
public protocol SubtitlesCodable {
	/// The file extension supported by the coder
	static var extn: String { get }
	/// Create an instance of the coder
	static func Create() -> Self

	/// Decode subtitles from the specified data
	/// - Parameters:
	///   - data: The data to decode
	///   - encoding: The expected string encoding if the coder represents a text file
	/// - Returns: The subtitles
	func decode(_ data: Data, encoding: String.Encoding) throws -> Subtitles

	/// Encode the specified subtitles to a data
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	///   - encoding: The string encoding to use if the coder generates text
	/// - Returns: The encoded data
	func encode(subtitles: Subtitles, encoding: String.Encoding) throws -> Data
}

/// A protocol for indicating that the coder generates text content
public protocol SubtitlesTextCodable {
	/// Decode subtitles from the specified string
	/// - Parameters:
	///   - content: The string to decode
	/// - Returns: The subtitles
	func decode(_ content: String) throws -> Subtitles

	/// Encode the specified subtitles to a string
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	/// - Returns: The encoded string
	func encode(subtitles: Subtitles) throws -> String
}

public extension SubtitlesCodable {
	/// The file extension supported by the coder
	var extn: String { Self.extn }

	/// Decode the subtitles from a file
	/// - Parameters:
	///   - fileURL: The url for the file to load
	///   - encoding: The expected encoding for the file
	/// - Returns: Subtitles
	func decode(fileURL: URL, encoding: String.Encoding) throws -> Subtitles {
		if fileURL.pathExtension.lowercased() != self.extn {
			Swift.print("Mismatched extensions?")
		}

		if let coder = self as? SubtitlesTextCodable {
			/// This coder encodes/decodes text
			let content = try String(contentsOf: fileURL, encoding: encoding)
			return try coder.decode(content)
		}

		let data = try Data(contentsOf: fileURL)
		return try self.decode(data, encoding: encoding)
	}
}

extension Subtitles {
	/// Coder namespace
	public class Coder {
		/// Disable construction of 'Coder'
		private init() {}
	}
}

extension Subtitles.Coder {
	/// Retrieve a coder that supports the specified file extension
	/// - Parameter fileExtension: The file extension for the coder
	/// - Returns: The coder, or nil if a coder cannot be found
	public static func coder(fileExtension: String) -> SubtitlesCodable? {
		let extn = fileExtension.lowercased()
		return Self.coders.first(where: { $0.extn == extn })?.Create()
	}

	/// The supported coders
	private static let coders: [SubtitlesCodable.Type] = [
		Subtitles.Coder.SRT.self,
		Subtitles.Coder.VTT.self,
		Subtitles.Coder.SBV.self,
		Subtitles.Coder.JSON.self,
		Subtitles.Coder.SUB.self,
		Subtitles.Coder.CSV.self,
	]
}
