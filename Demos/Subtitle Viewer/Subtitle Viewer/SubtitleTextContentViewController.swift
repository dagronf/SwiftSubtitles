//
//  SubtitleTextContentViewController.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 7/4/2024.
//

import Foundation
import AppKit

import SwiftSubtitles

class SubtitleTextContentViewController: NSViewController {
	@IBOutlet var textView: NSTextView!
	
	var content: String = "" {
		didSet {
			self.setText(self.content)
		}
	}

	private func setText(_ text: String) {
		let a = NSMutableAttributedString(
			string: text,
			attributes: [
				NSAttributedString.Key.font: NSFont.userFixedPitchFont(ofSize: 13),
				NSAttributedString.Key.foregroundColor: NSColor.textColor
			])

		self.textView.textStorage?.setAttributedString(a)
	}

}
