//
//  SRT+entry.swift
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

// MARK: - Cue

public extension Subtitles {
	/// An cue entry in an SRT file
	struct Cue: Equatable {
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

		/// Create a Cue entry
		public init(
			identifier: String? = nil,
			position: Int? = nil,
			startTime: Time,
			endTime: Time,
			text: String
		) {
			assert(startTime < endTime)
			assert(text.count > 0)
			self.identifier = identifier
			self.position = position
			self.startTime = startTime
			self.endTime = endTime
			self.text = text
		}
	}
}
