//
//  ViewController.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 9/5/2023.
//

import Cocoa
import SwiftSubtitles

class SubtitleViewController: NSViewController {

	@IBOutlet weak var subtitleTableView: NSTableView!

	weak var document: DocumentContent? {
		didSet {
			self.subtitleTableView.reloadData()
		}
	}

	var subtitles: Subtitles? { self.document?.subtitles }

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(
			forName: ContentChangedNotificationTitle,
			object: document,
			queue: .main) { [weak self] _ in
				self?.subtitleTableView.reloadData()
			}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

extension SubtitleViewController: NSTableViewDelegate, NSTableViewDataSource {

	func numberOfRows(in tableView: NSTableView) -> Int {
		self.subtitles?.cues.count ?? 0
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let cue = subtitles?.cues[row] else {
			return nil
		}

		if tableColumn?.identifier.rawValue == "line" {
			guard
				let raw = subtitleTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("startCell"), owner: self),
				let cell = raw as? NSTableCellView
			else {
				fatalError()
			}
			cell.textField?.stringValue = "\(row + 1)"
			cell.textField?.alignment = .right
			cell.textField?.textColor = NSColor.tertiaryLabelColor
//			cell.wantsLayer = true
//			cell.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
			return cell
		}
		else if tableColumn?.identifier.rawValue == "id" {
			guard
				let raw = subtitleTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("startCell"), owner: self),
				let cell = raw as? NSTableCellView
			else {
				fatalError()
			}
			cell.textField?.alignment = .left

			if let i = cue.identifier {
				cell.textField?.stringValue = "\(i)"
			}
			else {
				cell.textField?.stringValue = "-"
				cell.textField?.textColor = NSColor.tertiaryLabelColor
				cell.textField?.alignment = .center
			}

			return cell
		}
		else if tableColumn?.identifier.rawValue == "position" {
			guard
				let raw = subtitleTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("startCell"), owner: self),
				let cell = raw as? NSTableCellView
			else {
				fatalError()
			}
			if let i = cue.position {
				cell.textField?.stringValue = "\(i)"
				cell.textField?.alignment = .right
			}
			else {
				cell.textField?.stringValue = "-"
				cell.textField?.textColor = NSColor.tertiaryLabelColor
				cell.textField?.alignment = .center
			}
			return cell
		}
		else if tableColumn?.identifier.rawValue == "startTime" {
			guard
				let raw = subtitleTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("startCell"), owner: self),
				let cell = raw as? NSTableCellView
			else {
				fatalError()
			}
			cell.textField?.stringValue = cue.startTime.text
			return cell
		}
		else if tableColumn?.identifier.rawValue == "endTime" {
			guard
				let raw = subtitleTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("endCell"), owner: self),
				let cell = raw as? NSTableCellView
			else {
				fatalError()
			}
			cell.textField?.stringValue = cue.endTime.text
			return cell
		}
		else if tableColumn?.identifier.rawValue == "speaker" {
			guard
				let raw = subtitleTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("startCell"), owner: self),
				let cell = raw as? NSTableCellView
			else {
				fatalError()
			}

			if let speaker = cue.speaker {
				cell.textField?.alignment = .natural
				cell.textField?.textColor = NSColor.textColor
				cell.textField?.stringValue = speaker
			}
			else {
				cell.textField?.stringValue = "-"
				cell.textField?.alignment = .center
				cell.textField?.textColor = NSColor.tertiaryLabelColor
			}
			return cell
		}
		else if tableColumn?.identifier.rawValue == "text" {
			guard
				let raw = subtitleTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("startCell"), owner: self),
				let cell = raw as? NSTableCellView
			else {
				fatalError()
			}
			cell.textField?.stringValue = cue.text
			cell.textField?.maximumNumberOfLines = 10
			return cell
		}

		return nil
	}

}
