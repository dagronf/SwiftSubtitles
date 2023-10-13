//
//  TextEncodingAccessoryView.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 10/5/2023.
//

import Cocoa

// https://github.com/apple/swift-corelibs-foundation/blob/main/CoreFoundation/String.subproj/CFStringEncodingExt.h

private let encodingMap: [(String, String.Encoding)] = [
	("(auto)", .utf8),
	("-1", String.Encoding(rawValue: 1024)),
	("Unicode (UTF-8)", .utf8),
	("Unicode (UTF-16)", .utf16),
	("-2", String.Encoding(rawValue: 1024)),
	("Unicode (UTF-16 Big-Endian)", .utf16BigEndian),
	("Unicode (UTF-16 Little-Endian)", .utf16LittleEndian),
	("Unicode (UTF-32)", .utf32),
	("Unicode (UTF-32 Big-Endian)", .utf32BigEndian),
	("-3", String.Encoding(rawValue: 1024)),
	("Japanese (JIS)", .iso2022JP),
	("Western (ISO Latin 1)", .isoLatin1),
	("Western (ISO Latin 2)", .isoLatin2),
	("Japanese (EUC)", .japaneseEUC),
	("Western (macOS Roman)", .macOSRoman),
]

class TextEncodingAccessoryView: NSViewController {

	@IBOutlet weak var encodingPopup: NSPopUpButton!
	@IBOutlet var decodedTextView: NSTextView!

	@IBOutlet weak var stateLabel: NSTextField!

	/// The currently selected encoding. Nil represents 'auto'
	fileprivate(set) var encoding: String.Encoding?
	var selectedFile: URL?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		setup()
	}

	func setup() {

		self.stateLabel.isHidden = true

		self.encodingPopup.removeAllItems()

		self.decodedTextView.isVerticallyResizable = true
		self.decodedTextView.isHorizontallyResizable = true
		self.decodedTextView.autoresizingMask = [.height, .width]

		let encs = String.availableStringEncodings
		let encodingMap2 = encs.compactMap {
			if let e = CFStringGetNameOfEncoding(CFStringEncoding($0.rawValue)) {
				return (String(e), $0)
			}
			return nil
		}.sorted { a, b in a.0 < b.0 }

		let menu = NSMenu()
		menu.autoenablesItems = true

		encodingMap.forEach { key, value in
			if key.starts(with: "-") {
				menu.addItem(NSMenuItem.separator())
			}
			else {
				let m = NSMenuItem()
				m.title = key
				m.tag = (key == "(auto)") ? -1 : Int(value.rawValue)
				menu.addItem(m)
				m.target = self
				m.action = #selector(selectItem(_:))
			}
		}

		menu.addItem(NSMenuItem.separator())

		encodingMap2.forEach { key, value in
			if value == String.Encoding(rawValue: 1024) {
				menu.addItem(NSMenuItem.separator())
			}
			else {
				let m = NSMenuItem()
				m.title = key
				m.tag = Int(value.rawValue)
				menu.addItem(m)
				m.target = self
				m.action = #selector(selectItem(_:))
			}
		}

		self.encodingPopup.menu = menu
		self.encodingPopup.selectItem(at: 0)

		//self.encodingPopup.autoenablesItems = true

		self.decodedTextView.font = NSFont.userFixedPitchFont(ofSize: 11)

		self.sync()
	}

	@objc func selectItem(_ item: NSMenuItem) {
		if item.tag == -1 {
			self.encoding = nil
		}
		else {
			self.encoding = String.Encoding(rawValue: UInt(item.tag))
		}
		self.sync()
	}

	func sync() {
		guard let selection = self.selectedFile else {
			self.stateLabel.stringValue = "No selection"
			self.stateLabel.isHidden = false
			self.decodedTextView.string = ""
			return
		}

		do {
			let textContent: String?
			if let encoding = self.encoding {
				textContent = try String(contentsOf: selection, encoding: encoding)
			}
			else {
				var usedEncoding: String.Encoding = .ascii
				textContent = try String(contentsOf: selection, usedEncoding: &usedEncoding)
				Swift.print(textContent)
			}

			if let text = textContent, !text.isEmpty {
				self.decodedTextView.string = text
				self.stateLabel.isHidden = true
			}
			else {
				self.stateLabel.isHidden = false
				self.stateLabel.stringValue = "Unable to decode"
				self.decodedTextView.string = ""
			}
		}
		catch {
			Swift.print(error)
		}
	}
}

extension TextEncodingAccessoryView: NSOpenSavePanelDelegate {
	func panelSelectionDidChange(_ sender: Any?) {
		self.selectedFile = (sender as? NSOpenPanel)?.urls.first
		self.sync()
	}
}
