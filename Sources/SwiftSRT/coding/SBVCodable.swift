//
//  File.swift
//
//
//  Created by Darren Ford on 7/5/2023.
//

import DSFRegex
import Foundation

/*

 0:00:00.599,0:00:04.160
 >> ALICE: Hi, my name is Alice Miller and this is John Brown

 0:00:04.160,0:00:06.770
 >> JOHN: and we're the owners of Miller Bakery.

 0:00:06.770,0:00:10.880
 >> ALICE: Today we'll be teaching you how to make
 our famous chocolate chip cookies!

 0:00:10.880,0:00:16.700
 [intro music]

 0:00:16.700,0:00:21.480
 Okay, so we have all the ingredients laid out here

 */

// https://support.google.com/youtube/answer/2734698?hl=en#zippy=%2Cbasic-file-formats%2Cadvanced-file-formats%2Csubviewer-sbv-example

private let SBVTimeRegex__ = try! DSFRegex(#"^(\d+):(\d{1,2}):(\d{1,2})\.(\d{3}),(\d+):(\d{2}):(\d{1,2})\.(\d{3})$"#)

extension Subtitles {
	struct SBVCodable: SubtitlesCodable {
		static var extn: String { "sbv" }
	}
}

extension Subtitles.SBVCodable {

	func encode(subtitles: Subtitles) throws -> String {
		var result = ""

		try subtitles.entries.enumerated().forEach { item in
			let entry = item.element
			let s = entry.startTime
			let e = entry.endTime
			result += String(
				format: "%02d:%02d:%02d.%03d,%02d:%02d:%02d.%03d\n",
				s.hour, s.minute, s.second, s.millisecond,
				e.hour, e.minute, e.second, e.millisecond
			)

			if entry.text.isEmpty {
				throw Subtitles.SRTError.missingText(item.offset)
			}

			result += "\(entry.text)\n\n"
		}

		return result
	}

	func decode(_ content: String) throws -> Subtitles {

		var results = [Subtitles.Entry]()

		let lines = content.components(separatedBy: .newlines)

		var position: Int = 1

		var index = 0
		while index < lines.count {

			// Skip blank lines
			while index < lines.count && lines[index].isEmpty {
				index += 1
			}

			if index == lines.count {
				break
			}

			let timeLine = lines[index]
			let matches = SBVTimeRegex__.matches(for: timeLine)
			guard matches.count == 1 else {
				throw Subtitles.SRTError.invalidTime(index)
			}

			let captures = matches[0].captures
			guard captures.count == 8 else {
				throw Subtitles.SRTError.invalidTime(index)
			}

			guard
				let s_hour = UInt(timeLine[captures[0]]),
				let s_min = UInt(timeLine[captures[1]]),
				let s_sec = UInt(timeLine[captures[2]]),
				let s_ms = UInt(timeLine[captures[3]]),

				let e_hour = UInt(timeLine[captures[4]]),
				let e_min = UInt(timeLine[captures[5]]),
				let e_sec = UInt(timeLine[captures[6]]),
				let e_ms = UInt(timeLine[captures[7]])
			else {
				throw Subtitles.SRTError.invalidTime(index)
			}

			let s = Subtitles.Time(hour: s_hour, minute: s_min, second: s_sec, millisecond: s_ms)
			let e = Subtitles.Time(hour: e_hour, minute: e_min, second: e_sec, millisecond: e_ms)

			guard s < e else {
				throw Subtitles.SRTError.startTimeAfterEndTime(index)
			}

			index += 1

			// Text should be next
			var text = ""
			// Skip to the next blank
			while index < lines.count && lines[index].isEmpty == false {
				if !text.isEmpty { text += "\n" }
				text += lines[index]
				index += 1
			}

			if text.isEmpty {
				throw Subtitles.SRTError.invalidTime(index)
			}

			let entry = Subtitles.Entry(position: position, startTime: s, endTime: e, text: text)
			results.append(entry)
			position += 1
		}
		return Subtitles(entries: results)
	}
}
