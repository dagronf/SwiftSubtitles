//
//  SubtitleTextContentViewController.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 7/4/2024.
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
