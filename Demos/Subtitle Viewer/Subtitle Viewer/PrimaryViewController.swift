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

class PrimaryViewController: NSViewController {

	@IBOutlet weak var container: NSView!
	@IBOutlet weak var encodingField: NSTextField!
	@IBOutlet weak var cueCountField: NSTextField!
	@IBOutlet weak var startField: NSTextField!

	weak var document: DocumentContent? {
		didSet {
			if let _ = document {
				self.updateContent()
			}
		}
	}

	weak var splitView: NSSplitViewController?
	weak var subtitlesView: SubtitleViewController?
	weak var textView: SubtitleTextContentViewController?

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "split" {
			guard
				let splitView = segue.destinationController as? NSSplitViewController,
				let subtitlesView = splitView.splitViewItems[0].viewController as? SubtitleViewController,
				let textView = splitView.splitViewItems[1].viewController as? SubtitleTextContentViewController
			else {
				fatalError()
			}

			self.splitView = splitView
			self.subtitlesView = subtitlesView
			self.textView = textView
		}
	}

	private func updateContent() {
		guard let document = document else { return }

		self.subtitlesView?.document = document
		self.textView?.document = document

		self.updateUI()
	}

	private func updateUI() {
		guard let document = document else { return }

		let t = document.textContent.encodingText
		encodingField.stringValue = "\(t)"

		let count = document.subtitles.cues.count
		cueCountField.stringValue = "\(count)"

		if
			let s = document.subtitles.firstCue?.startTime.text,
			let e = document.subtitles.lastCue?.endTime.text
		{
			startField.stringValue = "\(s) - \(e)"
		}
		else {
			startField.stringValue = ""
		}
	}

	@IBAction func changeEncoding(_ sender: Any) {
		guard let document = document else { return }
		let panel = TextEncodingPanel(fileURL: document.textContent.fileURL)
		self.view.window?.beginSheet(panel) { [weak self] response in
			guard let `self` = self else { return }
			if response == .cancel {
				return
			}

			self.document?.changeEncoding(panel.selectedEncoding)

			self.updateUI()
		}
	}
}
