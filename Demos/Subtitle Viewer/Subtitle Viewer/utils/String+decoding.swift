//
//  Copyright © 2025 Darren Ford. All rights reserved
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

//  Auto-detect string encoding

extension String {

	/// A decoded text string along with text's encoding
	struct Decoded {
		/// The encoding
		let encoding: String.Encoding
		/// The text
		let text: String
	}

	/// Decode a swift string from a file attempting to infer the string encoding
	/// - Parameter fileURL: The file to load
	/// - Returns: The string and its encoding, or nil if the string encoding could not be inferred
	static func decode(from fileURL: URL) throws -> String.Decoded? {
		do {
			// Try the basic encoding first.
			// https://forums.swift.org/t/what-is-the-default-encoding-of-string-contentsof/38406/2
			var enc: String.Encoding = .utf8
			let text = try String(contentsOf: fileURL, usedEncoding: &enc)
			return Decoded(encoding: enc, text: text)
		}
		catch {
			// Swift.print(error)
			// Could not auto-detect the encoding using the 'basic' loader
			// Fall through to the NSString decoder
		}
		return decode(from: try Data(contentsOf: fileURL))
	}

	/// Decode a swift string from data attempting to infer the string encoding
	/// - Parameter data: The data to decode
	/// - Returns: The string and its encoding, or nil if the string encoding could not be inferred
	static func decode(from data: Data) -> String.Decoded?  {
#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
		var decodedString: NSString? = nil
		var usedLossy: ObjCBool = false
		let usedEncoding = NSString.stringEncoding(
			for: data,
			encodingOptions: [.allowLossyKey: false],
			convertedString: &decodedString,
			usedLossyConversion: &usedLossy
		)

		if usedEncoding > 0, let str = decodedString {
			return String.Decoded(encoding: String.Encoding(rawValue: usedEncoding), text: String(str))
		}
#endif
		return nil
	}
}
