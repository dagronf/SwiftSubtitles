//
//  Data+extensions.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 10/5/2023.
//

import Foundation

extension Data {
	/// Load a maximum of 'maxByteCount' bytes from a file
	init(fileURL: URL, maxByteCount: Int) throws {

		guard let stream = InputStream(url: fileURL) else {
			throw CocoaError(.fileNoSuchFile)
		}

		// Allocate a c-style buffer to write into
		let buffer_pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxByteCount)
		defer { buffer_pointer.deallocate() }

		// Open the stream
		stream.open()
		defer { stream.close() }

		var result = Data()

		var upper = maxByteCount
		while upper > 0 {
			let bytesRead = stream.read(buffer_pointer, maxLength: upper)
			if bytesRead == 0 {
				// No more data in the stream
				break
			}
			result.append(buffer_pointer, count: bytesRead)
			upper -= bytesRead
		}

		self = result
	}
}
