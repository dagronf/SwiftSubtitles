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

import SwiftSubtitles

class SubtitleTextContentViewController: NSViewController {
	@IBOutlet var textView: NSTextView!
	
	weak var document: DocumentContent?

	// The content model
	var textContent: ContentModel { document!.textContent }

	override func viewWillAppear() {
		super.viewWillAppear()

		self.textView.lnv_setUpLineNumberView()

		NotificationCenter.default.addObserver(
			forName: ContentChangedNotificationTitle,
			object: document,
			queue: .main) { [weak self] _ in
				guard let `self` = self else { return }
				self.setText(self.textContent.text)
			}
	}

	override func viewDidAppear() {
		super.viewDidAppear()
		self.setText(textContent.text)
	}

	private func setText(_ text: String?) {
		let v = NSMutableParagraphStyle()
		v.paragraphSpacing = 5
		let a = NSMutableAttributedString(
			string: text ?? "",
			attributes: [
				NSAttributedString.Key.font: NSFont.userFixedPitchFont(ofSize: 13) as Any,
				NSAttributedString.Key.foregroundColor: NSColor.textColor,
				NSAttributedString.Key.paragraphStyle: v
			])

		self.textView.textStorage?.setAttributedString(a)

		self.textView.lineNumberView.needsDisplay = true
	}
}
