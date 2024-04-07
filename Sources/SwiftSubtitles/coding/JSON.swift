//
//  JSON.swift
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

extension Subtitles.Coder {
	/// A JSON coder
	public struct JSON: SubtitlesCodable, SubtitlesTextCodable {
		public static var extn: String { "json-subtitles" }
		public static func Create() -> Self { JSON() }
		public init() { }
	}
}

public extension Subtitles.Coder.JSON {
	/// Encode subtitles as Data
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	///   - encoding: The encoding to use if the content is text
	/// - Returns: The encoded Data
	func encode(subtitles: Subtitles, encoding: String.Encoding) throws -> Data {
		try JSONEncoder().encode(subtitles)
	}

	/// Encode subtitles as a String
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	/// - Returns: The encoded String
	func encode(subtitles: Subtitles) throws -> String {
		let data = try self.encode(subtitles: subtitles, encoding: .utf8)
		guard let content = String(data: data, encoding: .utf8) else {
			throw SubTitlesError.invalidEncoding
		}
		return content
	}
}

public extension Subtitles.Coder.JSON {
	/// Decode subtitles from json data
	/// - Parameters:
	///   - data: The data to decode
	///   - encoding: The string encoding for the data content
	/// - Returns: Subtitles
	func decode(_ data: Data, encoding: String.Encoding) throws -> Subtitles {
		try JSONDecoder().decode(Subtitles.self, from: data)
	}

	/// Decode subtitles from a json string
	/// - Parameters:
	///   - content: The string
	/// - Returns: Subtitles
	func decode(_ content: String) throws -> Subtitles {
		guard let data = content.data(using: .utf8) else {
			throw SubTitlesError.invalidEncoding
		}
		return try self.decode(data, encoding: .utf8)
	}
}
