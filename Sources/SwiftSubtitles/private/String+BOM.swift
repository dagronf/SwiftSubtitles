//
//  String+BOM.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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

/// With thanks to [Marcin Krzyzanowski](https://gist.github.com/krzyzanowskim)
/// https://gist.github.com/krzyzanowskim/f2ca3e1e4f6dfd490fc35630b823eaac

/// The character \uFEFF is the BOM character for all UTFs (8, 16 LE and 16 BE)
private let _bom: Character = "\u{feff}"

extension String {
	/// Returns true if the string starts with a known BOM character
	func hasBOM() -> Bool { self.first == _bom }

	/// Remove a BOM character from the start of the string if it exists
	func removingBOM() -> String {
		(self.first == _bom) ? String(self.dropFirst()) : self
	}
}
