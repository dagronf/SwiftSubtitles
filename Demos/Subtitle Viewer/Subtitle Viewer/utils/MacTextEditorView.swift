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
import SwiftUI

struct MacTextEditorView: NSViewRepresentable {
	@Binding var text: String
	func makeNSView(context: Context) -> NSScrollView {
		let theTextView = NSTextView.scrollableTextView()
		let textView = (theTextView.documentView as! NSTextView)
		textView.delegate = context.coordinator
		textView.isEditable = false
		textView.string = text
		theTextView.contentInsets = NSEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

		textView.lnv_setUpLineNumberView()

		return theTextView
	}

	func updateNSView(_ nsView: NSScrollView, context: Context) {
		let v = NSMutableParagraphStyle()
		v.paragraphSpacing = 5
		let a = NSMutableAttributedString(
			string: text,
			attributes: [
				NSAttributedString.Key.font: NSFont.userFixedPitchFont(ofSize: 13) as Any,
				NSAttributedString.Key.foregroundColor: NSColor.textColor,
				NSAttributedString.Key.paragraphStyle: v
			])

		let textView = (nsView.documentView as! NSTextView)
		textView.textStorage?.setAttributedString(a)

		textView.lineNumberView.needsDisplay = true
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
}

extension MacTextEditorView {

	class Coordinator: NSObject, NSTextViewDelegate{

		var parent: MacTextEditorView
		var affectedCharRange: NSRange?

		init(_ parent: MacTextEditorView) {
			self.parent = parent
		}

		func textDidChange(_ notification: Notification) {
			guard let textView = notification.object as? NSTextView else {
				return
			}

			//Update text
			self.parent.text = textView.string
		}

		func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
			return true
		}
	}
}
