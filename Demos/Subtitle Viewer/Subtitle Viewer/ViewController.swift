//
//  ViewController.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 9/5/2023.
//

import Cocoa
import SwiftSubtitles

class ViewController: NSViewController {

	@IBOutlet weak var subtitleTableView: NSTableView!

	var subtitles: Subtitles? {
		didSet {
			self.subtitleTableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {

	func numberOfRows(in tableView: NSTableView) -> Int {
		subtitles?.cues.count ?? 0
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let cue = subtitles?.cues[row] else {
			return nil
		}

		if tableColumn?.identifier.rawValue == "startTime" {
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
		else if tableColumn?.identifier.rawValue == "text" {
			guard
				let raw = subtitleTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("textCell"), owner: self),
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
