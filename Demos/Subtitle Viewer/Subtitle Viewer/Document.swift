//
//  Document.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 9/5/2023.
//

import Cocoa
import SwiftSubtitles

import SwiftUI

protocol DocumentContent: AnyObject {
	var textContent: ContentModel { get }
	var subtitles: Subtitles { get }

	func changeEncoding(_ enc: String.Encoding?)
	func close()
}

let ContentChangedNotificationTitle = NSNotification.Name("ContentChangedNotificationTitle")

class Document: NSDocument, DocumentContent {

	var textContent: ContentModel
	public fileprivate(set) var subtitles: Subtitles = Subtitles([])

	override init() {
		self.textContent = ContentModel(fileURL: URL(fileURLWithPath: ""))
		super.init()
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)

		guard let c = windowController.contentViewController as? PrimaryViewController else {
			fatalError()
		}

		c.document = self
	}

	override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func read(from url: URL, ofType typeName: String) throws {
				/// Attempt to load the text from the URL
		self.textContent = ContentModel(fileURL: url)

		if let content = self.textContent.text {
			self.subtitles = try Subtitles(content: content, expectedExtension: url.pathExtension)
		}
	}

	func changeEncoding(_ enc: String.Encoding?) {
		self.textContent = self.textContent.reopen(using: enc)
		if let content = self.textContent.text {
			do {
				self.subtitles = try Subtitles(content: content, expectedExtension: fileURL!.pathExtension)
			}
			catch {
				self.subtitles = Subtitles.empty
			}
		}

		NotificationCenter.default.post(name: ContentChangedNotificationTitle, object: self)
	}
}
