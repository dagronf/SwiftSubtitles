//
//  ContentModel.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 10/4/2024.
//

import Foundation

class ContentModel: ObservableObject {
	/// The file URL
	let fileURL: URL

	/// The decoded text
	@Published private(set) var text: String?

	/// Is the content valid?
	var isValid: Bool { self.text != nil }

	/// The encoding to apply to the content of the file
	var encoding: String.Encoding? = nil {
		didSet {
			self.encodingDidChange()
		}
	}

	/// Returns a string containing the encoding
	var encodingText: String {
		if let encoding = encoding {
			return "\(encoding)"
		}
		else {
			return "<unknown>"
		}
	}

	init(fileURL: URL) {
		self.fileURL = fileURL
		self.encodingDidChange()
	}

	init(fileURL: URL, encoding: String.Encoding) {
		self.fileURL = fileURL
		self.encoding = encoding
		self.encodingDidChange()
	}

	init(fileURL: URL, text: String, encoding: String.Encoding) {
		self.fileURL = fileURL
		self.encoding = encoding
		self.text = text
	}

	func reopen(using encoding: String.Encoding?) -> ContentModel {
		if let e = encoding {
			return ContentModel(fileURL: fileURL, encoding: e)
		}
		else {
			return ContentModel(fileURL: fileURL)
		}
	}
}

private extension ContentModel {
	func encodingDidChange() {
		if let e = self.encoding {
			// Attemp to load using the specified encoding
			self.text = try? String(contentsOf: self.fileURL, encoding: e)
		}
		else {
			if let decoded = try? String.decode(from: self.fileURL) {
				self.encoding = decoded.encoding
				self.text = decoded.text
			}
			else {
				self.text = nil
			}
		}
	}
}
