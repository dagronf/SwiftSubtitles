//
//  File.swift
//  
//
//  Created by Darren Ford on 7/5/2023.
//

import DSFRegex
import Foundation

/*
 0:00:01.000,0:00:03.000
 Hello, and welcome to our video!

 0:00:04.000,0:00:06.000
 In this video, we will be discussing the SBV file format.

 0:00:07.000,0:00:10.000
 The SBV format is commonly used for storing subtitles for videos.
 */

/*

 WEBVTT

 00:00:01.000 --> 00:00:05.330
 Good day everyone, my name is June Doe.

 00:00:07.608 --> 00:00:15.290
 This video teaches you how to
 build a sandcastle on any beach.

 */

// 2 - ASDFASDF
// 3
private let CueRegex__ = try! DSFRegex(#"^(\d)(?:\s(.*))?$"#)

private let VTTTimeRegex__ = try! DSFRegex(#"(?:(\d*):)?(?:(\d*):)(\d*)\.(\d{3})\s-->\s(?:(\d*):)?(?:(\d*):)(\d*)\.(\d{3})"#)

extension Subtitles {
	/// VTT codable file
	///
	/// https://developer.mozilla.org/en-US/docs/Web/API/WebVTT_API
	struct VTTCodable: SubtitlesCodable {
		static var extn: String { "vtt" }
	}
}

extension Subtitles.VTTCodable {

	func encode(subtitles: Subtitles) throws -> String {
		var result = "WEBVTT\n\n"

		subtitles.entries.forEach { entry in
			if let position = entry.position {
				result += "\(position)"
			}
			if let title = entry.title {
				result += " \(title)"
			}
			result += "\n"

			let s = entry.startTime
			let e = entry.endTime
			result += String(
				format: "%02d:%02d:%02d.%03d --> %02d:%02d:%02d.%03d\n",
				s.hour, s.minute, s.second, s.millisecond,
				e.hour, e.minute, e.second, e.millisecond
			)

			result += "\(entry.text)\n\n"
		}

		return result
	}

	func decode(_ content: String) throws -> Subtitles {

		var results = [Subtitles.Entry]()

		let lines = content.components(separatedBy: .newlines)
		guard lines.count > 0 else {
			throw Subtitles.SRTError.invalidFile
		}
		guard lines[0].starts(with: "WEBVTT") else {
			throw Subtitles.SRTError.invalidFile
		}

		var index = 1

		while index < lines.count {
			// Skip blank lines
			while index < lines.count && lines[index].isEmpty {
				index += 1
			}
			if index == lines.count {
				break
			}

			if lines[index].starts(with: "NOTE") || lines[index].starts(with: "STYLE") {
				// Skip to the next blank
				while index < lines.count && lines[index].isEmpty == false {
					index += 1
				}
				index += 1
			}

			guard index < lines.count else {
				throw Subtitles.SRTError.invalidFile
			}

			// Optional cue position
			var position: Int? = nil
			var title: String? = nil
			do {
				let cueTitle = lines[index]
				let matches = CueRegex__.matches(for: cueTitle)
				if matches.matches.count == 1 {
					let captures = matches[0].captures
					if let cueIndex = Int(cueTitle[captures[0]]) {
						position = cueIndex
					}
					else {
						position = nil
					}

					let t = cueTitle[captures[1]]
					if t.isEmpty == false {
						title = String(t)
					}
					// Move to the next line
					index += 1
				}
			}

			// Time
			let timeLine = lines[index]
			let matches = VTTTimeRegex__.matches(for: timeLine)
			guard matches.matches.count == 1 else {
				throw Subtitles.SRTError.invalidTime(index)
			}
			let captures = matches[0].captures
			guard captures.count == 8 else {
				throw Subtitles.SRTError.invalidTime(index)
			}

			let s_hour = UInt(timeLine[captures[0]]) ?? 0
			let s_min = UInt(timeLine[captures[1]]) ?? 0

			let e_hour = UInt(timeLine[captures[4]]) ?? 0
			let e_min = UInt(timeLine[captures[5]]) ?? 0

			guard 
				let s_sec = UInt(timeLine[captures[2]]),
				let s_ms = UInt(timeLine[captures[3]]),
				let e_sec = UInt(timeLine[captures[6]]),
				let e_ms = UInt(timeLine[captures[7]])
			else {
				throw Subtitles.SRTError.invalidTime(index)
			}

			let s = Subtitles.Time(hour: s_hour, minute: s_min, second: s_sec, millisecond: s_ms)
			let e = Subtitles.Time(hour: e_hour, minute: e_min, second: e_sec, millisecond: e_ms)

			index += 1

			// next is the text
			var text = ""
			// Skip to the next blank
			while index < lines.count && lines[index].isEmpty == false {
				if !text.isEmpty {
					text += "\n"
				}
				text += lines[index]
				index += 1
			}

			let entry = Subtitles.Entry(title: title, position: position, startTime: s, endTime: e, text: text)
			results.append(entry)

			index += 1
		}
		return Subtitles(entries: results)
	}
}
