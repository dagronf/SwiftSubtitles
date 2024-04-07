//
//  DocumentController.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 7/4/2024.
//

import Foundation
import AppKit

import SwiftSubtitles

/// Note that this is instantiated in the Storyboard
class DocumentController: NSDocumentController {

	/// auto encoding == nil
	static var selected: String.Encoding? = nil

	var openAccessory: TextEncodingAccessoryView? = nil

//	override func documentClass(forType typeName: String) -> AnyClass? {
//		let c = super.documentClass(forType: typeName)
//		Swift.print(c)
//		Swift.print(typeName)
//		return c
//	}

	override func openDocument(_ sender: Any?) {
		let a = TextEncodingAccessoryView()
		self.openAccessory = a

		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = false
		openPanel.allowedFileTypes = ["srt", "sub", "vtt", "sbv", "csv"]

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
