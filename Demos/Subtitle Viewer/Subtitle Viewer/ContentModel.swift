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
