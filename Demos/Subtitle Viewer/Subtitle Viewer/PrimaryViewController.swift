//
//  PrimaryViewController.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 10/4/2024.
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
