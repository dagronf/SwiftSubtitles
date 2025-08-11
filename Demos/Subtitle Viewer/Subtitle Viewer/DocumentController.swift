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
import AppKit
import SwiftUI

import UniformTypeIdentifiers
import SwiftSubtitles

/// Note that this is instantiated in the Storyboard
class DocumentController: NSDocumentController {

	override func documentClass(forType typeName: String) -> AnyClass? {
		return Document.self
	}

	static var selected: String.Encoding? = nil
	var openAccessory: TextEncodingAccessoryView? = nil

	override func openDocument(_ sender: Any?) {
		let a = TextEncodingAccessoryView()
		self.openAccessory = a

		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = false

		openPanel.allowedContentTypes = [
			UTType.srt,
			UTType.sub,
			UTType.vtt,
			UTType.sbv,
			UTType.commaSeparatedText,
			UTType.json,
			UTType.lrc,
			UTType.ttml,
			UTType.advancedsubstationalpha,
			UTType.substationalpha,
		]

		openPanel.accessoryView = a.view
		openPanel.delegate = openAccessory
		openPanel.begin { [weak self] response in
			guard response == NSApplication.ModalResponse.OK else {
				return
			}

			guard let `self` = self else { return }

			self.openAccessory = nil

			DocumentController.selected = a.encoding

			guard let selectedURL = openPanel.urls.first else { return }
			self.openDocument(
				withContentsOf: selectedURL,
				display: true
			) { document, t, error in
				if let e = error {
					let l = NSAlert(error: e)
					l.runModal()
				}
			}
		}
	}
}
