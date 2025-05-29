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

import Foundation

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11.0, iOS 14, tvOS 14, watchOS 7, *)
extension UTType {
	public static var ttml: UTType {
		UTType(importedAs: "public.ttml", conformingTo: .xml)
	}
}
#endif

public extension Subtitles.Coder {
	/// TTML (MicroDVD) decoder/encoder
	struct TTML: SubtitlesCodable, SubtitlesTextCodable {
		public static var extn: String { "ttml" }
		public static func Create() -> Self { TTML() }
	}
}

public extension Subtitles.Coder.TTML {
	/// Encode subtitles as Data
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	///   - encoding: The encoding to use if the content is text
	/// - Returns: The encoded Data
	func encode(subtitles: Subtitles, encoding: String.Encoding) throws -> Data {
		let str = try self.encode(subtitles: subtitles)
		guard let data = str.data(using: encoding) else {
			throw SubTitlesError.invalidEncoding
		}
		return data
	}

	/// Encode subtitles as a String
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	/// - Returns: The encoded String
	func encode(subtitles: Subtitles) throws -> String {

		var result = """
<?xml version="1.0" encoding="UTF-8"?>
<tt xmlns="http://www.w3.org/ns/ttml" xmlns:tts="http://www.w3.org/ns/ttml#styling" xmlns:ttp="http://www.w3.org/ns/ttml#parameter" xml:lang="en" ttp:timeBase="media">
	<body>
		<div>
"""

		subtitles.cues.forEach { cue in
			result += "<p "

			// Identifier if specified
			if let identifier = cue.identifier {
				result += "xml:id=\"\(identifier)\" "
			}

			result += "begin=\"\(cue.startTime.ttmlTimeExpressionString)\" "
			result += "end=\"\(cue.endTime.ttmlTimeExpressionString)\" "
			result += ">"
			result += cue.text.xmlEscaped().replacingOccurrences(of: "\n", with: "<br/>")
			result += "</p>\n"
		}

		result += """
		</div>
	</body>
</tt>
"""

		return result
	}
}

public extension Subtitles.Coder.TTML {
	/// Decode subtitles from sbv data
	/// - Parameters:
	///   - data: The data to decode
	///   - encoding: The string encoding for the data content
	/// - Returns: Subtitles
	func decode(_ data: Data, encoding: String.Encoding) throws -> Subtitles {
		throw SubTitlesError.coderDoesntSupportEncoding
	}

	/// Decode subtitles from a sbv-coded string
	/// - Parameters:
	///   - content: The string
	/// - Returns: Subtitles
	func decode(_ content: String) throws -> Subtitles {
		throw SubTitlesError.coderDoesntSupportEncoding
	}
}
