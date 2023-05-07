//
//  SRT+time.swift
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

public extension Subtitles {
	/// A time definition for an SRT file
	struct Time: Equatable, Comparable {
		/// Create a Time
		public init(hour: UInt = 0, minute: UInt = 0, second: UInt = 0, millisecond: UInt = 0) {
			self.hour = hour
			assert(minute < 60)
			self.minute = minute
			assert(second < 60)
			self.second = second
			assert(millisecond < 1000)
			self.millisecond = millisecond
		}

		/// Create a new Time instance from a TimeInterval
		public init(interval: TimeInterval) {
			let time = UInt(interval)
			self.millisecond = UInt((interval.truncatingRemainder(dividingBy: 1)) * 1000)
			self.second = time % 60
			self.minute = (time / 60) % 60
			self.hour = (time / 3600)
		}

		/// The hour
		public let hour: UInt
		/// The minute
		public let minute: UInt
		/// The second
		public let second: UInt
		/// The millisecond
		public let millisecond: UInt

		/// Return the time value as a TimeInterval
		public var timeInterval: TimeInterval {
			(Double(self.hour) * 3600) + (Double(self.minute) * 60) + Double(self.second) + (Double(self.millisecond) / 1000)
		}

		/// Sort two time entries
		public static func < (lhs: Subtitles.Time, rhs: Subtitles.Time) -> Bool {
			lhs.hour < rhs.hour ||
			lhs.minute < rhs.minute ||
			lhs.second < rhs.second ||
			lhs.millisecond < rhs.millisecond
		}
	}
}
