import Foundation

extension Subtitles.Coder {
	/// A JSON coder
	public struct JSONPodcastIndex: SubtitlesCodable, SubtitlesTextCodable, Codable {
		public static var extn: String { "json" }
		public static func Create() -> Self { JSONPodcastIndex() }
		public init() {
			version = "1.0.0"
			segments = []
		}

		public init(version: String, segments: [Segment]) {
			self.version = version
			self.segments = segments
		}

		public struct Segment: Codable {
			let speaker: String?
			let startTime: Double
			let endTime: Double
			let body: String
		}

		let version: String
		let segments: [Segment]
	}
}

public extension Subtitles.Coder.JSONPodcastIndex {
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
		return try JSONEncoder().encode(Subtitles.Coder.JSONPodcastIndex(version: "1.0.0", segments: segments))
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

public extension Subtitles.Coder.JSONPodcastIndex {
	/// Decode subtitles from json data
	/// - Parameters:
	///   - data: The data to decode
	///   - encoding: The string encoding for the data content
	/// - Returns: Subtitles
	func decode(_ data: Data, encoding: String.Encoding) throws -> Subtitles {
		let value =  try JSONDecoder().decode(Subtitles.Coder.JSONPodcastIndex.self, from: data)
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
