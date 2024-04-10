//
//  DocumentController.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 7/4/2024.
//

import Foundation
import AppKit
import SwiftUI

import SwiftSubtitles

/// Note that this is instantiated in the Storyboard
class DocumentController: NSDocumentController {
	override func openDocument(_ sender: Any?) {
		let a = TextEncodingAccessoryView()
		self.openAccessory = a

		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = false
		openPanel.allowedFileTypes = ["srt", "sub", "vtt", "sbv", "csv", "json"]

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
