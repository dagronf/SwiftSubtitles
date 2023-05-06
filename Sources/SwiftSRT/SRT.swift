//
//  SRT.swift
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

/// An SRT file representation
public struct SRT {
	/// The entries in the SRT
	public internal(set) var entries: [Entry] = []
}

// MARK: - Decoding

public extension SRT {
	/// Create an SRT object using the contents of a file
	/// - Parameter fileURL: The file URL for the SRT content
	init(fileURL: URL) throws {
		try self.decode(fileURL: fileURL)
	}

	/// Create an SRT object from the content of a string
	/// - Parameter content: The string containing the SRT content
	@inlinable init(content: String) throws {
		try self.decode(content)
	}

	/// Create an SRT object from the content of a Data
	/// - Parameters:
	///   - data: The data containing the SRT content
	///   - encoding: The expected text encoding
	@inlinable init(data: Data, encoding: String.Encoding = .utf8) throws {
		try self.decode(data: data, encoding: encoding)
	}
}

// MARK: - Encoding

public extension SRT {
	/// Encode the entries into an SRT-compatible string
	@inlinable @inline(__always)
	func encode() -> String {
		self._encode()
	}

	/// Encode the SRT entries as a Data object
	/// - Parameter encoding: The encoding to use
	/// - Returns: The encoded SRT
	func data(encoding: String.Encoding = .utf8) throws -> Data {
		guard
			let data = self._encode().data(using: encoding, allowLossyConversion: false)
		else {
			throw SRTError.invalidEncoding
		}
		return data
	}
}

// MARK: - Sorting

public extension SRT {
	/// Return a new SRT object with the entries sorted by the position
	var positionSorted: SRT {
		let entries = self.entries.sorted { a, b in a.position < b.position }
		return SRT(entries: entries)
	}

	/// Return a new SRT object with the entries sorted by start time of each entry
	var startTimeSorted: SRT {
		let entries = self.entries.sorted { a, b in a.startTime < b.endTime }
		return SRT(entries: entries)
	}
}
