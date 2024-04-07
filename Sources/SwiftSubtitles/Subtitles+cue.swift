//
//  Subtitles+cue.swift
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

public extension Subtitles {

	/// The unique identifier type for a Cue
	typealias CueIdentifier = Identifier<Cue, UUID>

	/// An cue entry in a subtitles file
	struct Cue: Equatable, Identifiable, Codable {
		/// A unique identifier for _this_ object. It is not involved in equality checks
		public let id: CueIdentifier

		/// The identifier (used in VTT)
		public let identifier: String?
		/// The position (used in SRT)
		public let position: Int?
		/// The time to present the cue entry
		public let startTime: Time
		/// The time to dismiss the cue entry
		public let endTime: Time
		/// The text for the cue entry
		public let text: String

		/// The start time in seconds
		@inlinable public var startTimeInSeconds: Double { self.startTime.timeInSeconds }
		/// The end time in seconds
		@inlinable public var endTimeInSeconds: Double { self.endTime.timeInSeconds }
		/// The duration of the cue in seconds
		@inlinable public var duration: Double { self.endTimeInSeconds - self.startTimeInSeconds }

		/// Is the start time and end time valid?
		@inlinable public var isValidTime: Bool { self.startTimeInSeconds >= 0 && self.duration > 0 }

		/// Check if two cues are equal.
		///
		/// This equality check does NOT take into account `id`
		public static func == (lhs: Cue, rhs: Cue) -> Bool {
			lhs.identifier == rhs.identifier &&
			lhs.position == rhs.position &&
			lhs.startTime == rhs.startTime &&
			lhs.endTime == rhs.endTime &&
			lhs.text == rhs.text
		}

		/// Create a Cue entry
		/// - Parameters:
		///   - identifier: The cue identifier (optional)
		///   - position: The cue position (optional) - used for SRT encoding/decoding
		///   - startTime: The time to start displaying the cue
		///   - endTime: The time to stop displaying the cue
		///   - text: The cue text
		public init(
			identifier: String? = nil,
			position: Int? = nil,
			startTime: Time,
			endTime: Time,
			text: String
		) {
			assert(startTime < endTime)
			self.id = Identifier<Self, UUID>(id: UUID())
			
			self.identifier = identifier
			self.position = position
			self.startTime = startTime
			self.endTime = endTime
			self.text = text
		}

		/// Create a Cue entry
		/// - Parameters:
		///   - identifier: The cue identifier (optional)
		///   - position: The cue position (optional) - used for SRT encoding/decoding
		///   - startTimeInSeconds: The time to start displaying the cue
		///   - endTimeInSeconds: The time to stop displaying the cue
		///   - text: The cue text
		public init(
			identifier: String? = nil,
			position: Int? = nil,
			startTimeInSeconds: Double,
			endTimeInSeconds: Double,
			text: String
		) {
			assert(startTimeInSeconds <= endTimeInSeconds)
			self.id = Identifier<Self, UUID>(id: UUID())

			self.identifier = identifier
			self.position = position
			self.startTime = Time(timeInSeconds: startTimeInSeconds)
			self.endTime = Time(timeInSeconds: endTimeInSeconds)
			self.text = text
		}

		/// Create a cue entry from a start time and duration
		/// - Parameters:
		///   - identifier: The cue's identifier
		///   - position: The cue's position
		///   - startTime: The start time for the cue
		///   - duration: The duration (in seconds) for the cue
		///   - text: The cue's text
		public init(
			identifier: String? = nil,
			position: Int? = nil,
			startTime: Time,
			duration: Double,
			text: String
		) {
			assert(duration >= 0)

			self.id = Identifier<Self, UUID>(id: UUID())
			self.identifier = identifier
			self.position = position
			self.text = text

			self.startTime = startTime
			self.endTime = Time(timeInSeconds: startTime.timeInSeconds + duration)
		}

		/// Create a cue entry from a start time and duration
		/// - Parameters:
		///   - identifier: The cue's identifier
		///   - position: The cue's position
		///   - startTime: The start time (in seconds) for the cue
		///   - duration: The duration (in seconds) for the cue
		///   - text: The cue's text
		public init(
			identifier: String? = nil,
			position: Int? = nil,
			startTime: Double,
			duration: Double,
			text: String
		) {
			assert(startTime >= 0)
			assert(duration >= 0)

			self.init(
				identifier: identifier,
				position: position,
				startTime: .init(timeInSeconds: startTime),
				duration: duration,
				text: text
			)
		}

		/// Returns true if this cue contains the seconds value
		@inlinable public func contains(timeInSeconds seconds: Double) -> Bool {
			seconds >= self.startTimeInSeconds && seconds <= self.endTimeInSeconds
		}

		/// Returns true if this cue contains the time value
		@inlinable public func contains(time: Time) -> Bool {
			self.contains(timeInSeconds: time.timeInSeconds)
		}

		/// Does the cue start after the specified time
		/// - Parameter timeInSeconds: The time to check
		/// - Returns: True if the cue occurs AFTER the specified time, false otherwise
		@inlinable public func startsAfter(timeInSeconds seconds: Double) -> Bool {
			self.endTimeInSeconds > seconds
		}

		/// Does the cue start after the specified time
		/// - Parameter time: The time to check
		/// - Returns: True if the cue occurs AFTER the specified time, false otherwise
		@inlinable public func startsAfter(time: Time) -> Bool {
			self.startsAfter(timeInSeconds: time.timeInSeconds)
		}
	}
}

// MARK: - Time shifting

public extension Subtitles.Cue {
	/// Time-shift the cue
	/// - Parameter durationInSeconds: The time in seconds to shift the cue (negative to shift the time backwards)
	/// - Returns: A new cue
	func timeshifting(by durationInSeconds: Double) -> Subtitles.Cue {
		// Clamp the lower bound to 0
		let startTime = max(0, self.startTimeInSeconds + durationInSeconds)
		// Clamp let end time to the start time
		let endTime = max(startTime, self.endTime.timeInSeconds + durationInSeconds)
		return Subtitles.Cue(
			identifier: self.identifier,
			position: self.position,
			startTimeInSeconds: startTime,
			endTimeInSeconds: endTime,
			text: self.text
		)
	}

	/// Create a new cue by inserting a time duration
	/// - Parameters:
	///   - durationInSeconds: The duration to insert
	///   - timeInSeconds: The time at which to insert the duration
	/// - Returns: A new cue
	///
	/// Shift this cue backwards or forwards in time, clamping to zero
	func inserting(_ durationInSeconds: Double, at timeInSeconds: Double) -> Subtitles.Cue {
		if self.contains(timeInSeconds: timeInSeconds) {
			// Insert the duration within this cue
			return self.inserting(durationInSeconds: durationInSeconds)
		}
		else if self.startsAfter(timeInSeconds: timeInSeconds) {
			// Time-shift the entire cue by the duration
			return self.timeshifting(by: durationInSeconds)
		}
		else {
			// Nothing to do!
			return self
		}
	}

	/// Insert a duration within the cue
	/// - Parameter durationInSeconds: The duration (in seconds) to insert into the cue
	/// - Returns: A new cue
	///
	/// If the resulting end time is less that then start time, it is clamped to the start time (thus zero duration)
	func inserting(durationInSeconds: Double) -> Subtitles.Cue {
		return Subtitles.Cue(
			identifier: self.identifier,
			position: self.position,
			startTimeInSeconds: self.startTimeInSeconds,
			endTimeInSeconds: max(self.startTimeInSeconds, self.endTimeInSeconds + durationInSeconds),
			text: self.text
		)
	}
}
