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

private let SRTTimeRegex__ = try! DSFRegex(#"(\d+):(\d{1,2}):(\d{1,2}),(\d{3})\s-->\s(\d+):(\d{2}):(\d{1,2}),(\d{3})"#)

extension Subtitles {
	struct SRTCodable: SubtitlesCodable {
		static var extn: String { "srt" }
	}
}

extension Subtitles.SRTCodable {

	func encode(subtitles: Subtitles) throws -> String {
		var result = ""

		var position: Int = 0

		subtitles.entries.forEach { entry in
			if !result.isEmpty {
				result += "\n"
			}

			if let p = entry.position {
				position = p
			}
			else {
				position += 1
			}

			result += "\(position)\n"

			let s = entry.startTime
			let e = entry.endTime
			result += String(
				format: "%02d:%02d:%02d,%03d --> %02d:%02d:%02d,%03d\n",
				s.hour, s.minute, s.second, s.millisecond,
				e.hour, e.minute, e.second, e.millisecond
			)

			result += "\(entry.text)\n"
		}

		return result
	}

	func decode(_ content: String) throws -> Subtitles {

		enum LineState {
			case blank
			case position
			case time
			case text
		}

		var results = [Subtitles.Entry]()

		let lines = content.components(separatedBy: .newlines)

		var currentState: LineState = .blank

		var position: Int = -1
		var start: Subtitles.Time?
		var end: Subtitles.Time?
		var text: String = ""

		try lines.enumerated().forEach { item in
			let line = item.element.trimmingCharacters(in: .whitespaces)

			if line.isEmpty {
				if currentState == .blank {
					// just another separating line
				}
				else if currentState == .text {
					guard let s = start, let e = end else {
						throw Subtitles.SRTError.invalidFile
					}

					// srt entry is complete
					if text.isEmpty {
						throw Subtitles.SRTError.missingText(item.offset)
					}
					results.append(Subtitles.Entry(position: position, startTime: s, endTime: e, text: text))

					position = -1
					start = nil
					end = nil
					text = ""

					currentState = .blank
				}
				else {
					throw Subtitles.SRTError.invalidFile
				}
			}
			else {
				// Line has content
				if currentState == .blank {
					// Should be the position
					guard let p = Int(line) else {
						throw Subtitles.SRTError.invalidPosition(item.offset + 1)
					}
					position = p
					currentState = .position
				}
				else if currentState == .position {
					// Should be the start/end  "00:05:00,400 --> 00:05:15,300"
					let matches = SRTTimeRegex__.matches(for: line)
					guard matches.count == 1 else {
						throw Subtitles.SRTError.invalidTime(item.offset)
					}

					let captures = matches[0].captures
					guard captures.count == 8 else {
						throw Subtitles.SRTError.invalidTime(item.offset)
					}

					guard
						let s_hour = UInt(line[captures[0]]),
						let s_min = UInt(line[captures[1]]),
						let s_sec = UInt(line[captures[2]]),
						let s_ms = UInt(line[captures[3]]),

						let e_hour = UInt(line[captures[4]]),
						let e_min = UInt(line[captures[5]]),
						let e_sec = UInt(line[captures[6]]),
						let e_ms = UInt(line[captures[7]])
					else {
						throw Subtitles.SRTError.invalidTime(item.offset)
					}

					let s = Subtitles.Time(hour: s_hour, minute: s_min, second: s_sec, millisecond: s_ms)
					let e = Subtitles.Time(hour: e_hour, minute: e_min, second: e_sec, millisecond: e_ms)

					guard s < e else {
						throw Subtitles.SRTError.startTimeAfterEndTime(item.offset)
					}

					start = s
					end = e

					currentState = .text
				}
				else if currentState == .text {
					if text.isEmpty == false {
						text += "\n"
					}
					text += line
				}
			}
		}

		if position != -1 {
			guard let s = start, let e = end else {
				throw Subtitles.SRTError.invalidTime(-1)
			}

			let entry = Subtitles.Entry(position: position, startTime: s, endTime: e, text: text)
			results.append(entry)
		}

		return Subtitles(entries: results)
	}
}
