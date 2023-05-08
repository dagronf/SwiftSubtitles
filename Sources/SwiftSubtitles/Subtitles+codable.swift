//
//  File.swift
//  
//
//  Created by Darren Ford on 9/5/2023.
//

import Foundation

/// Subtitles codable protocol
public protocol SubtitlesCodable {
	/// The file extension supported by the coder
	static var extn: String { get }
	/// Create an instance of the coder
	static func Create() -> Self

	/// Decode subtitles from the specified string
	func decode(_ content: String) throws -> Subtitles
	/// Encode the specified subtitles to a string
	func encode(subtitles: Subtitles) throws -> String
}

extension Subtitles {
	public class Coder {
		private init() {}
	}

	/// A subtitle coder factory
	public class Factory {
		/// A common factory for instantiating coders
		public static let shared = Factory()

		/// Returns a coder that supports the specified file extension
		public func coder(fileExtension: String) -> SubtitlesCodable? {
			self.coders.first(where: { $0.extn == fileExtension })?.Create()
		}

		/// The supported coders
		private let coders: [SubtitlesCodable.Type] = [
			Subtitles.Coder.SRT.self,
			Subtitles.Coder.VTT.self,
			Subtitles.Coder.SBV.self,
		]
	}
}
