//
//  RSVerticallyCenteredTextFieldCell.swift
//  DSFInspectorPanes
//
//  Created by Darren Ford on 21/7/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//
//  3rd party licenses
//
//  Makes use of RSVerticallyCenteredTextFieldCell
//  Red Sweater Software: http://www.red-sweater.com/blog/148/what-a-difference-a-cell-makes)
//  License - http://opensource.org/licenses/mit-license.php
//
//  MIT License
//
//  Copyright (c) 2019 Darren Ford
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

#if os(macOS)

import Cocoa

// MARK: - Vertically centered text field

/// Class for vertically centering text within an NSTextField
///
/// Adapted from Red Sweater Software, LLC for [RSVerticallyCenteredTextFieldCell](http://www.red-sweater.com/blog/148/what-a-difference-a-cell-makes) component
///
/// [License (MIT)](http://opensource.org/licenses/mit-license.php)
internal class RSVerticallyCenteredTextFieldCell: NSTextFieldCell {
	var mIsEditingOrSelecting: Bool = false

	override func drawingRect(forBounds theRect: NSRect) -> NSRect {
		// Get the parent's idea of where we should draw
		var newRect: NSRect = super.drawingRect(forBounds: theRect)

		// When the text field is being edited or selected, we have to turn off the magic because it screws up
		// the configuration of the field editor.  We sneak around this by intercepting selectWithFrame and editWithFrame and sneaking a
		// reduced, centered rect in at the last minute.

		if !self.mIsEditingOrSelecting {
			// Get our ideal size for current text
			let textSize: NSSize = self.cellSize(forBounds: theRect)

			// Center in the proposed rect
			let heightDelta: CGFloat = newRect.size.height - textSize.height
			if heightDelta > 0 {
				newRect.size.height -= heightDelta
				newRect.origin.y += heightDelta / 2
			}
		}

		return newRect
	}

	override func select(
		withFrame rect: NSRect,
		in controlView: NSView,
		editor textObj: NSText,
		delegate: Any?,
		start selStart: Int,
		length selLength: Int
	) {
		let arect = self.drawingRect(forBounds: rect)
		self.mIsEditingOrSelecting = true
		super.select(withFrame: arect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
		self.mIsEditingOrSelecting = false
	}

	override func edit(
		withFrame rect: NSRect,
		in controlView: NSView,
		editor textObj: NSText,
		delegate: Any?,
		event: NSEvent?
	) {
		let aRect = self.drawingRect(forBounds: rect)
		self.mIsEditingOrSelecting = true
		super.edit(withFrame: aRect, in: controlView, editor: textObj, delegate: delegate, event: event)
		self.mIsEditingOrSelecting = false
	}
}

#endif
