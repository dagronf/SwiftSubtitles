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

		/// Retrieve a coder that supports the specified file extension
		/// - Parameter fileExtension: The file extension for the coder
		/// - Returns: The coder, or nil if a coder cannot be found
		public static func coder(fileExtension: String) -> SubtitlesCodable? {
			let extn = fileExtension.lowercased()
			return Self.coders.first(where: { $0.extn == extn })?.Create()
		}

		/// The supported coders
		private static let coders: [SubtitlesCodable.Type] = [
			Subtitles.Coder.SRT.self,
			Subtitles.Coder.VTT.self,
			Subtitles.Coder.SBV.self,
		]
	}
}
