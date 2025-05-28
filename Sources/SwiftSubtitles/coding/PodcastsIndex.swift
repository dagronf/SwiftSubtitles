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

// An encoder/decoder for the Podcast Index Transcript format
//
// See: https://github.com/Podcastindex-org/podcast-namespace/blob/main/transcripts/transcripts.md#json

import Foundation

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11.0, iOS 14, tvOS 14, watchOS 7, *)
extension UTType {
	public static var podcastsIndex: UTType {
		UTType(importedAs: "public.podcastsindex", conformingTo: .json)
	}
}
#endif

extension Subtitles.Coder {
	/// A [Podcast Index Transcript](https://github.com/Podcastindex-org/podcast-namespace/blob/main/transcripts/transcripts.md#json) encoder/decoder
	public struct PodcastsIndex: SubtitlesCodable, SubtitlesTextCodable, Codable {
		public static var extn: String { "json" }
		public static func Create() -> Self { PodcastsIndex() }
		public init() {
			version = "1.0.0"
			segments = []
		}

		public init(version: String, segments: [Segment]) {
			self.version = version
			self.segments = segments
		}

		/// A segment
		public struct Segment: Codable {
			/// The segment speaker
			let speaker: String?
			/// Start time in seconds
			let startTime: Double
			/// End time in seconds
			let endTime: Double
			/// The text for the segment
			let body: String
		}

		let version: String
		let segments: [Segment]
	}
}

public extension Subtitles.Coder.PodcastsIndex {
	/// Encode subtitles as Data
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	///   - encoding: The encoding to use if the content is text
	/// - Returns: The encoded Data
	func encode(subtitles: Subtitles, encoding: String.Encoding) throws -> Data {
		var segments = [Segment]()
		for cue in subtitles.cues {
			let segment = Segment(
				speaker: cue.speaker ?? "",
				startTime: cue.startTimeInSeconds,
				endTime: cue.endTimeInSeconds,
				body: cue.text
			)
			segments.append(segment)
		}
		return try JSONEncoder().encode(Subtitles.Coder.PodcastsIndex(version: "1.0.0", segments: segments))
	}

	/// Encode subtitles as a String
	/// - Parameters:
	///   - subtitles: The subtitles to encode
	/// - Returns: The encoded String
	func encode(subtitles: Subtitles) throws -> String {
		let data = try self.encode(subtitles: subtitles, encoding: .utf8)
		guard let content = String(data: data, encoding: .utf8) else {
			throw SubTitlesError.invalidEncoding
		}
		return content
	}
}

public extension Subtitles.Coder.PodcastsIndex {
	/// Decode subtitles from json data
	/// - Parameters:
	///   - data: The data to decode
	///   - encoding: The string encoding for the data content
	/// - Returns: Subtitles
	func decode(_ data: Data, encoding: String.Encoding) throws -> Subtitles {
		let value =  try JSONDecoder().decode(Subtitles.Coder.PodcastsIndex.self, from: data)
		var cues = [Subtitles.Cue]()
		for segment in value.segments {
			let cue = Subtitles.Cue(
				startTime: Subtitles.Time(timeInSeconds: segment.startTime),
				duration: segment.endTime - segment.startTime,
				text: segment.body,
				speaker: segment.speaker
			)
			cues.append(cue)
		}
		return Subtitles(cues)
	}

	/// Decode subtitles from a json string
	/// - Parameters:
	///   - content: The string
	/// - Returns: Subtitles
	func decode(_ content: String) throws -> Subtitles {
		guard let data = content.data(using: .utf8) else {
			throw SubTitlesError.invalidEncoding
		}
		return try self.decode(data, encoding: .utf8)
	}
}
