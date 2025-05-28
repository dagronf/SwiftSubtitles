//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

extension String.Encoding {
	static let separator = String.Encoding(rawValue: 1024)
	static let auto = String.Encoding(rawValue: 1025)
}

struct TextEncodings {

	static let shared = TextEncodings()

	struct Encoding: Identifiable, Hashable {

		static let auto = Encoding(name: "Autodetect encoding", value: .auto)

		let id = UUID()
		let name: String
		let value: String.Encoding

		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}

	init() {
		let encs = String.availableStringEncodings
		self.allEncodings = encs.compactMap {
			if let e = CFStringGetNameOfEncoding(CFStringEncoding($0.rawValue)) {
				return Encoding(name: String(e), value: $0)
			}
			return nil
		}.sorted { a, b in a.name < b.name }
	}

	let autoEncoding = [ Encoding.auto ]
	var auto: Encoding { autoEncoding[0] }

	let defaultEncodings = [
		Encoding(name: "Unicode (UTF-8)", value: .utf8),
		Encoding(name: "Unicode (UTF-16)", value: .utf16),
		Encoding(name: "Unicode (UTF-16 Big-Endian)", value: .utf16BigEndian),
		Encoding(name: "Unicode (UTF-16 Little-Endian)", value: .utf16LittleEndian),
		Encoding(name: "Unicode (UTF-32)", value: .utf32),
		Encoding(name: "Unicode (UTF-32 Big-Endian)", value: .utf32BigEndian),
		Encoding(name: "Japanese (JIS)", value: .iso2022JP),
		Encoding(name: "Western (ISO Latin 1)", value: .isoLatin1),
		Encoding(name: "Western (ISO Latin 2)", value: .isoLatin2),
		Encoding(name: "Japanese (EUC)", value: .japaneseEUC),
		Encoding(name: "Western (Mac OS Roman)", value: .macOSRoman),
	]
	let allEncodings: [Encoding]

	func defaultEncodings(_ search: String) -> [Encoding] {
		if search.isEmpty { return defaultEncodings }
		return defaultEncodings.filter {
			$0.name.lowercased().contains(search.lowercased())
		}
	}

	func allEncodings(_ search: String) -> [Encoding] {
		if search.isEmpty { return allEncodings }
		return allEncodings.filter {
			$0.name.lowercased().contains(search.lowercased())
		}
	}
}
