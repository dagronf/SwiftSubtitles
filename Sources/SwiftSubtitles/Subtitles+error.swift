//
//  Subtitles+error.swift
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

/// Errors thrown by the library
public enum SubTitlesError: Error {
	/// File type is not supported
	case unsupportedFileType(String)
	/// File is invalid
	case invalidFile
	/// Found end of file
	case unexpectedEOF
	/// Unsupported string encoding
	case invalidEncoding
	/// Expected an integer cue position
	case invalidPosition(Int)
	/// Time field could not be parsed
	case invalidTime(Int)
	/// End time occurs before the start time
	case startTimeAfterEndTime(Int)
	/// The text for a cue is missing
	case missingText(Int)
	/// Unexpected end of cue
	case unexpectedEndOfCue(Int)
	/// The coder only supports binary coding
	case coderGeneratesBinaryContent
	///
	case coderDoesntSupportEncoding
}
