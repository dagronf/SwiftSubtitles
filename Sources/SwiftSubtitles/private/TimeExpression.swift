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

import DSFRegex
import Foundation

// Time parsing as per the TTML spec
// https://www.w3.org/TR/ttml1/#timing-value-timeExpression

// MARK: - Data Models

/// Parsing a TTML TimeExpression
enum TimeExpression: Equatable {
	case time(TimeExpression.Clock)
	case duration(TimeExpression.Offset)

	static func parse(_ string: String?) -> TimeExpression? {
		guard let string else { return nil }
		return __parseTimeExpression(string)
	}

	/// Create a time value
	static func time(hours: Int, minutes: Int, seconds: Int, fraction: Int? = nil, frames: Int? = nil, subFrames: Int? = nil) -> TimeExpression {
		.time(TimeExpression.Clock(hours: hours, minutes: minutes, seconds: seconds, fraction: fraction, frames: frames, subFrames: subFrames))
	}

	/// Create a duration value
	static func offsetTime(value: Double, metric: Metric) -> TimeExpression {
		.duration(TimeExpression.Offset(value: value, metric: metric))
	}

	///  Convert a time expression value to a cue time
	/// - Returns: A cue time
	func asSubtitleCueTime() -> Subtitles.Time {
		switch self {
		case .duration(let d):
			return Subtitles.Time(timeInSeconds: d.value)
		case .time(let t):
			return Subtitles.Time(
				hour: UInt(t.hours.clamped(0 ... 999)),
				minute: UInt(t.minutes.clamped(0 ... 59)),
				second: UInt(t.seconds.clamped(0 ... 59)),
				millisecond: UInt((t.fraction ?? 0).clamped(0 ... 999))
			)
		}
	}
}

extension TimeExpression {
	enum Metric: String, CaseIterable, Equatable {
		case hours = "h"
		case minutes = "m"
		case seconds = "s"
		case milliseconds = "ms"
		case frames = "f"
		case ticks = "t"
	}

	/// An absolute clock time
	struct Clock: Equatable, Comparable {
		let hours: Int
		let minutes: Int
		let seconds: Int
		let fraction: Int?
		let frames: Int?
		let subFrames: Int?
		init(hours: Int, minutes: Int, seconds: Int, fraction: Int? = nil, frames: Int? = nil, subFrames: Int? = nil) {
			self.hours = hours
			self.minutes = minutes
			self.seconds = seconds
			self.fraction = fraction
			self.frames = frames
			self.subFrames = subFrames
		}

		/// Returns the TimeExpression string representation
		public var stringValue: String {
			let nf = NumberFormatter()
			nf.minimumFractionDigits = 0
			nf.maximumFractionDigits = 3
			nf.minimumIntegerDigits = 2
			nf.decimalSeparator = "."
			var result = "\(nf.string(for: hours)!):\(nf.string(for: minutes)!):\(nf.string(for: seconds)!)"
			if let fraction {
				result += ".\(fraction)"
			}
			else if let frames {
				result += ":\(nf.string(for: frames)!)"
				if let subFrames {
					result += ".\(subFrames)"
				}
			}
			return result
		}

		/// Return the raw seconds value for this time
		///
		/// If frames or subframes are used, this function returns nil
		var secondsValue: Double? {
			if self.frames != nil || self.subFrames != nil {
				return nil
			}
			var result: Double = Double(self.hours) * 3600
			result += Double(self.minutes) * 60
			result += Double(self.seconds)
			if let fraction {
				result += max(1.0, Double(fraction) / 1000.0)
			}
			return result
		}

		static func < (lhs: Clock, rhs: Clock) -> Bool {
			if lhs.hours < rhs.hours { return true }
			if lhs.minutes < rhs.minutes { return true }
			if lhs.seconds < rhs.seconds { return true }

			if let fraction = lhs.fraction {
				if fraction < (rhs.fraction ?? 0) { return true }
			}
			if let frames = lhs.frames {
				if frames < (rhs.frames ?? 0) { return true }
			}
			if let subFrames = lhs.subFrames {
				if subFrames < (rhs.subFrames ?? 0) { return true }
			}
			return false
		}
	}

	/// A relative clock time
	struct Offset: Equatable {
		let value: Double
		let metric: Metric
		init(value: Double, metric: Metric) {
			self.value = value
			self.metric = metric
		}

		/// Returns the TimeExpression string representation
		var stringValue: String {
			let nf = NumberFormatter()
			nf.minimumFractionDigits = 0
			nf.maximumFractionDigits = 3
			nf.minimumIntegerDigits = 1
			nf.decimalSeparator = "."
			return "\(nf.string(for: value)!)\(metric.rawValue)"
		}

		/// The offset as a seconds value
		///
		/// If frames or ticks is specified, this function returns nil
		var secondsValue: Double? {
			switch metric {
			case .hours:
				return value * 3600
			case .minutes:
				return value * 60
			case .seconds:
				return value
			case .milliseconds:
				return value / 1000.0
			case .frames:
				return nil
			case .ticks:
				return nil
			}
		}
	}
}

// MARK: - Extensions For Subtitles.Time

extension Subtitles.Time {
	/// Return this time as a TTML time expression
	/// - Returns: A time expression
	var ttmlTimeExpression: TimeExpression.Clock {
		return TimeExpression.Clock(
			hours: Int(self.hour),
			minutes: Int(self.minute),
			seconds: Int(self.second),
			fraction: Int(self.millisecond)
		)
	}

	/// Return this time as a TTML time formatted string
	var ttmlTimeExpressionString: String {
		self.ttmlTimeExpression.stringValue
	}
}

// MARK: - Parsing

private let __clockTimeRegex = try! DSFRegex(#"(\d{2,}):(\d{2}):(\d{2})(?:\.(\d+)|:(\d{2,})(?:\.(\d+))?)?"#)
private let __timeOffsetRegex = try! DSFRegex(#"(\d+(?:\.\d+)?)(ms|h|m|s|f|t)"#)

private func __parseTimeExpression(_ string: String) -> TimeExpression? {
	// Check if this is a clock time
	let clockMatches = __clockTimeRegex.matches(for: string)
	if clockMatches.matches.count == 1 {
		let captures = clockMatches.matches[0].captures
		if let hour = Int(string[captures[0]]),
		   let min = Int(string[captures[1]]),
		   let sec = Int(string[captures[2]])
		{
			let ms = Int(string[captures[3]])
			let frames = Int(string[captures[4]])
			let subframes = Int(string[captures[5]])
			let ct = TimeExpression.Clock(hours: hour, minutes: min, seconds: sec, fraction: ms, frames: frames, subFrames: subframes)
			return .time(ct)
		}
	}

	// Check if this is a duration
	let durationMatches = __timeOffsetRegex.matches(for: string)
	if durationMatches.matches.count == 1 {
		let captures = durationMatches.matches[0].captures
		if let duration = Double(string[captures[0]]),
		   let metric = TimeExpression.Metric(rawValue: String(string[captures[1]]))
		{
			let duration = TimeExpression.Offset(value: duration, metric: metric)
			return .duration(duration)
		}
	}

	// If we got here - no match
	return nil
}

/*

 <timeExpression>
 : clock-time
 | offset-time

 clock-time
 : hours ":" minutes ":" seconds ( fraction | ":" frames ( "." sub-frames )? )?

 offset-time
 : time-count fraction? metric

 hours
 : <digit> <digit>
 | <digit> <digit> <digit>+

 minutes | seconds
 : <digit> <digit>

 frames
 : <digit> <digit>
 | <digit> <digit> <digit>+

 sub-frames
 : <digit>+

 fraction
 : "." <digit>+

 time-count
 : <digit>+

 metric
 : "h"                 // hours
 | "m"                 // minutes
 | "s"                 // seconds
 | "ms"                // milliseconds
 | "f"                 // frames
 | "t"                 // ticks

 */
