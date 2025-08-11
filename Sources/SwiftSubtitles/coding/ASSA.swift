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

/// SSA - Sub Station Alpha v4 (*.ssa)
/// ASSA - Advanced Sub Station Alpha v4+ (*.ass)
///
/// * https://nikse.dk/subtitleedit/formats/assa
/// * https://fileformats.fandom.com/wiki/SubStation_Alpha
/// * http://www.tcax.org/docs/ass-specs.htm
/// * https://hhsprings.bitbucket.io/docs/programming/examples/ffmpeg/subtitle/ass.html
/// * https://wiki.multimedia.cx/index.php/SubStation_Alpha

import Foundation
import DSFRegex

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11.0, iOS 14, tvOS 14, watchOS 7, *)
extension UTType {
	public static var substationalpha: UTType {
		UTType(importedAs: "public.substationalpha.fileformat.ssa", conformingTo: .plainText)
	}
	public static var advancedsubstationalpha: UTType {
		UTType(importedAs: "public.substationalpha.fileformat.ass", conformingTo: .plainText)
	}
}
#endif

// MARK: - SubStation Alpha v4

public extension Subtitles.Coder {
	/// A SubStation Alpha subtitles coder
	///
	/// Doesn't support encoding
	struct SubStationAlpha: SubtitlesCodable, SubtitlesTextCodable {
		public static var extn: String { "ssa" }
		public static func Create() -> Subtitles.Coder.SubStationAlpha { SubStationAlpha() }

		public func encode(subtitles: Subtitles) throws -> String {
			throw SubTitlesError.coderDoesntSupportEncoding
		}
		public func encode(subtitles: Subtitles, encoding: String.Encoding) throws -> Data {
			throw SubTitlesError.coderDoesntSupportEncoding
		}
		public func decode(_ content: String) throws -> Subtitles {
			try AdvancedSSA().decode(content)
		}
		public func decode(_ data: Data, encoding: String.Encoding) throws -> Subtitles {
			try AdvancedSSA().decode(data, encoding: encoding)
		}
	}
}

// MARK: - Advanced SubStation Alpha v4+

public extension Subtitles.Coder {
	/// An Advanced SubStation Alpha subtitles coder
	///
	/// Doesn't support encoding
	struct AdvancedSSA: SubtitlesCodable, SubtitlesTextCodable {
		public static var extn: String { "ass" }
		public static func Create() -> Self { AdvancedSSA() }
	}
}

public extension Subtitles.Coder.AdvancedSSA {
	/// Encode subtitles as a String
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	/// - Returns: The encoded String
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

/// Parse a header eg. `[Script Info]` returns 'Script Info'
private let iniHeaderRegex = try! DSFRegex(#"(?<=\[)([^\]]+)(?=\])"#)
/// Parse a `name:value` pair
private let iniSettingRegex = try! DSFRegex(#"^(.+?(?=:)):(.*)$"#)

public extension Subtitles.Coder.AdvancedSSA {
	/// Decode subtitles from ASS data
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

	/// Decode subtitles from an ASS string
	/// - Parameters:
	///   - content: The string content to decode
	/// - Returns: Subtitles
	func decode(_ content: String) throws -> Subtitles {

		// The cues
		var results = [Subtitles.Cue]()

		// The expected dialog fields
		var expectedDialogueFields: [DialogueFormat] = []

		let lines = content.removingBOM().lines

		var currentHeader = ""
		for line in lines {
			guard line.count > 0 else {
				// empty line. Reset the current header (usually a spacing between headers)
				currentHeader = ""
				continue
			}

			// See if the line is a header
			let matches = iniHeaderRegex.matches(for: line)
			if matches.count == 1 {
				let captures = matches[0].captures
				if captures.count == 1 {
					currentHeader = String(line[captures[0]])
				}
				continue
			}

			let setting = iniSettingRegex.matches(for: line)
			guard setting.count == 1, setting[0].captures.count == 2 else {
				continue
			}
			let settingTitle = String(line[setting[0].captures[0]])
			let settingValue = String(line[setting[0].captures[1]]).trimmingCharacters(in: .whitespacesAndNewlines)

			// We only support version 4.00 and 4.00+
			if settingTitle == "ScriptType" && settingValue.hasPrefix("v4.00") == false {
				Swift.print("Unsupported script type \(settingValue)")
				throw SubTitlesError.invalidEncoding
			}

			// We don't care about anything that isn't inside an events header (for the moment)
			if currentHeader != "Events" {
				continue
			}

			if settingTitle == "Format" {
				expectedDialogueFields = try self.parseDialogFormat(value: settingValue)
			}
			else if settingTitle == "Dialogue" {
				let cue = try parseDialogue(format: expectedDialogueFields, settingText: settingValue)
				results.append(cue)
			}
		}
		return Subtitles(results)
	}

	fileprivate func parseDialogFormat(value: String) throws -> [DialogueFormat] {
		let fieldsText = value.components(separatedBy: ",")
		return fieldsText.map {
			let v = $0.trimmingCharacters(in: .whitespacesAndNewlines)
			return DialogueFormat(rawValue: v) ?? .Unknown
		}
	}

	fileprivate func parseDialogue(format: [DialogueFormat], settingText: String) throws -> Subtitles.Cue {
		guard format.count > 0 else {
			throw SubTitlesError.invalidEncoding
		}

		var startTime: Subtitles.Time?
		var endTime: Subtitles.Time?
		var dialogue: String?
		var actor: String?

		let components = settingText.components(separatedBy: ",")
		for field in format.enumerated() {
			if field.offset >= components.count {
				// There are fewer fields in the dialog components that appear in the fields definition
				// This is an error
				throw SubTitlesError.invalidEncoding
			}

			// Grab the field content, and trim whitespaces
			let fieldText = components[field.offset].trimmingCharacters(in: .whitespacesAndNewlines)

			if field.element == .Start {
				startTime = try TimeParsing.parseCommonTime(index: 0, timeString: fieldText)
			}
			else if field.element == .End {
				endTime = try TimeParsing.parseCommonTime(index: 0, timeString: fieldText)
			}
			else if field.element == .Actor {
				actor = fieldText
			}
			else if field.element == .Text {
				// Once we hit tht 'Text' field, everything following is text
				dialogue = components[field.offset...].joined().trimmingCharacters(in: .whitespacesAndNewlines)
				break
			}
		}

		guard let st = startTime, let et = endTime, let d = dialogue else {
			throw SubTitlesError.invalidEncoding
		}
		return Subtitles.Cue(startTime: st, endTime: et, text: d, speaker: actor)
	}
}

//	These contain the subtitle text, their timings, and how it should be displayed.
// The fields which appear in each Dialogue line are defined by a Format: line, which must appear before
// any events in the section. The format line specifies how SSA will interpret all following Event lines.
// The field names must be spelled correctly, and are as follows:
private enum DialogueFormat: String {
	case Marked
	case Layer
	case Start
	case End
	case Style
	case Name
	case MarginL
	case MarginR
	case MarginV
	case Effect
	case Text
	case Actor
	case Unknown   // Fallback for an unknown field type
}
