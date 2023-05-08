//
//  Subtitles+codable.swift
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

/// Subtitles codable protocol
public protocol SubtitlesCodable {
	/// The file extension supported by the coder
	static var extn: String { get }
	/// Create an instance of the coder
	static func Create() -> Self

	/// Decode subtitles from the specified string
	func decode(_ content: String) throws -> Subtitles
	/// Encode the specified subtitles to a string
	func encode(subtitles: Subtitles) throws -> String
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
	]
}
