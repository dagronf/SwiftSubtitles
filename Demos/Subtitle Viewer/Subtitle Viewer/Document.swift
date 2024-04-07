//
//  Document.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 9/5/2023.
//

import Cocoa
import SwiftSubtitles

class Document: NSDocument {

	var textContent: String = ""
	public fileprivate(set) var subtitles: Subtitles = Subtitles([])

	var contentViewController: NSViewController?

	override init() {
		super.init()
		// Add your subclass-specific initialization here.
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)

		guard 
			let split = windowController.contentViewController as? NSSplitViewController,
			let vc = split.splitViewItems[0].viewController as? ViewController,
			let te = split.splitViewItems[1].viewController as? SubtitleTextContentViewController
		else {
			fatalError()
		}

		vc.subtitles = subtitles
		te.content = self.textContent
	}

	override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func read(from url: URL, ofType typeName: String) throws {
		self.textContent = try String(contentsOf: url, encoding: DocumentController.selected ?? .utf8)
		self.subtitles = try Subtitles(fileURL: url, encoding: DocumentController.selected ?? .utf8)
	}
}

//public class UTI: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
//
//	private let rawCFValue: CFString
//
//	public lazy var rawValue: String = { self.rawCFValue as String }()
//
//	public var description: String {
//		let rawDescription = UTTypeCopyDescription(rawCFValue)?.takeRetainedValue()
//		return rawDescription.map { $0 as String } ?? self.rawValue
//	}
//	public var debugDescription: String { return self.rawValue }
//
//	private convenience init?(tagClass: CFString, tag: String, conformingTo: UTI?) {
//		guard let raw = UTTypeCreatePreferredIdentifierForTag(tagClass, tag as CFString, conformingTo?.rawCFValue) else { return nil }
//		let rawCFString = raw.takeRetainedValue()
//		self.init(rawCFString)
//	}
//
//	public convenience init?(fileExtension: String, conformingTo: UTI? = nil) {
//		self.init(tagClass: kUTTagClassFilenameExtension, tag: fileExtension, conformingTo: conformingTo)
//	}
//
//	public convenience init?(fileURL: URL, conformingTo: UTI? = nil) {
//		self.init(tagClass: kUTTagClassFilenameExtension, tag: fileURL.pathExtension, conformingTo: conformingTo)
//	}
//
//	public init(uti: String) {
//		self.rawCFValue = uti as CFString
//	}
//
//	public init(rawValue: String) {
//		self.rawCFValue = rawValue as CFString
//	}
//
//	public init(_ cfValue: CFString) {
//		self.rawCFValue = cfValue
//	}
//
//	public func conformsTo(_ other: UTI) -> Bool {
//		return UTTypeConformsTo(self.rawCFValue, other.rawCFValue)
//	}
//
//	public func hash(into hasher: inout Hasher) {
//		hasher.combine(self.rawValue)
//	}
//
//	public static func == (lhs: UTI, rhs: UTI) -> Bool {
//		return UTTypeEqual(lhs.rawCFValue, rhs.rawCFValue)
//	}
//
//	public lazy var isDynamic: Bool = { [unowned self] in
//		UTTypeIsDynamic(self.rawCFValue)
//	}()
//
//	public lazy var preferredMIMEType: String? = { [unowned self] in
//		self.preferredTag(for: kUTTagClassMIMEType)
//	}()
//
//	public lazy var preferredFileExtension: String? = { [unowned self] in
//		self.preferredTag(for: kUTTagClassFilenameExtension)
//	}()
//
//	public lazy var mimeTypes: [String] = { [unowned self] in
//		self.tags(for: kUTTagClassMIMEType)
//	}()
//
//	public lazy var fileExtensions: [String] = { [unowned self] in
//		self.tags(for: kUTTagClassFilenameExtension)
//	}()
//
//	private func preferredTag(for tagClass: CFString) -> String? {
//		guard let raw = UTTypeCopyPreferredTagWithClass(rawCFValue, tagClass) else { return nil }
//		return raw.takeRetainedValue() as String
//	}
//
//	private func tags(for tagClass: CFString) -> [String] {
//		guard let raw = UTTypeCopyAllTagsWithClass(rawCFValue, tagClass) else { return [] }
//		return raw.takeRetainedValue() as? [String] ?? []
//	}
//}
