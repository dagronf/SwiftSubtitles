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

#if canImport(FoundationXML)
// For non-apple platforms it seems that the XML parser has been shifted into its own module
import FoundationXML
#endif

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
	/// Decode subtitles from a sbv-coded string
	/// - Parameters:
	///   - content: The string
	/// - Returns: Subtitles
	func decode(_ content: String) throws -> Subtitles {
		guard let data = content.data(using: .utf8) else {
			throw SubTitlesError.invalidEncoding
		}
		return try self.decode(data, encoding: .utf8)
	}

	/// Decode subtitles from sbv data
	/// - Parameters:
	///   - data: The data to decode
	///   - encoding: The string encoding for the data content
	/// - Returns: Subtitles
	func decode(_ data: Data, encoding: String.Encoding) throws -> Subtitles {
		let parser = XMLParser(data: data)
		let decoder = TTMLDecoder()
		parser.delegate = decoder

		if parser.parse() == false {
			throw SubTitlesError.invalidFile
		}

		var results: [Subtitles.Cue] = []

		for subtitle in decoder.subtitles {
			guard let begin = TimeExpression.parse(subtitle.begin)?.asSubtitleCueTime() else {
				continue
			}

			let duration = TimeExpression.parse(subtitle.duration)?.asSubtitleCueTime()
			let end = TimeExpression.parse(subtitle.end)?.asSubtitleCueTime()

			let text = subtitle.text
				.xmlUnescaped()
				.lines
				.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
				.removingEmptyLines()
				.joined(separator: "\n")
				.xmlUnescaped()

			if let duration {
				results.append(Subtitles.Cue(startTime: begin, duration: duration.timeInSeconds, text: text))
			}
			else if let end {
				results.append(Subtitles.Cue(startTime: begin, endTime: end, text: text))
			}
			else {
				// ??
			}
		}
		if results.count == 0 {
			throw SubTitlesError.invalidEncoding
		}
		return Subtitles(results)
	}
}

class TTMLDecoder: NSObject, XMLParserDelegate {

	class ActiveSubtitle {
		var begin: String
		var duration: String?
		var end: String?
		var text = ""
		init(begin: String, duration: String?, end: String?) {
			self.begin = begin
			self.end = end
		}
	}

	var inBody = false
	var active: ActiveSubtitle?

	var subtitles: [ActiveSubtitle] = []

	var acceptableElements = ["p", "span", "div"]

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if elementName == "tt",
			attributeDict["xmlns"] != "http://www.w3.org/ns/ttml"
		{
			parser.abortParsing()
		}

		if elementName == "body" {
			inBody = true
		}
		else if acceptableElements.contains(elementName) && inBody == true {
			if	let begin = attributeDict["begin"] {
				let duration = attributeDict["dur"]
				let end = attributeDict["end"]
				self.active = ActiveSubtitle(begin: begin, duration: duration, end: end)
			}
		}
	}

	func parser(_ parser: XMLParser, foundCharacters string: String) {
		if let active {
			active.text += string
		}
	}

	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "body" {
			inBody = false
		}
		else if let active, acceptableElements.contains(elementName) && inBody == true {
			subtitles.append(active)
			self.active = nil
		}
		else if let active, elementName == "br" {
			active.text += "\n"
		}
	}
}
