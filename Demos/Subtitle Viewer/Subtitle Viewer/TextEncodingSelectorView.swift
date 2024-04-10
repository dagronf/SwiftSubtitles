//
//  TextEncodingSe;ectorView.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 8/4/2024.
//

import SwiftUI
import DSFSearchField

/// A panel allowing selection of a new text file encoding
class TextEncodingPanel: NSPanel {

	convenience init(fileURL: URL) {

		self.init(
			contentRect: NSRect(x: 20, y: 20, width: 500, height: 400),
			styleMask: [.nonactivatingPanel, .titled, .resizable, .closable, .fullSizeContentView],
			backing: .buffered,
			defer: false
		)

		self.setFrameAutosaveName("TextCodingPanelSize")

		let root = TextEncodingSelectorContentView(fileURL: fileURL) { [weak self] response, enc in
			guard let `self` = self else { return }
			self.selectedEncoding = enc
			self.sheetParent?.endSheet(self, returnCode: response)
		}

		let vc = NSHostingController(rootView: root)
		self.contentView = vc.view
	}

	var selectedEncoding: String.Encoding?
}

// --

struct TextEncodingSelectorView: View {
	let fileURL: URL
	@Binding var encoding: TextEncodings.Encoding
	@Binding var canUseEncoding: Bool

	var body: some View {
		HSplitView(content: {
			TextEncodingListView(encoding: $encoding)
				.frame(maxWidth: 300)
			FileDecodableTextView(
				fileURL: fileURL,
				encoding: encoding,
				canUseEncoding: $canUseEncoding
			)
		})
		.frame(maxHeight: .infinity)
	}
}

struct TextEncodingListView: View {
	@Binding var encoding: TextEncodings.Encoding
	@State var searchText: String = ""

	var body: some View {
		let encodings = TextEncodings.shared
		VStack(alignment: .leading, spacing: 0) {
			List(selection: $encoding) {
				if searchText.count == 0 {
					Section(content: {
						ForEach(encodings.autoEncoding, id: \.self) { item in
							Text(item.name)
								.listRowSeparator(.hidden)
						}
					}
					, header: {
						Text("Encoding")
					})
				}

				Section(content: {
					ForEach(encodings.defaultEncodings(searchText), id: \.self) { item in
						Text(item.name)
					}
				}, header: {
					Text("Common encodings")
				})

				Section(content: {
					ForEach(encodings.allEncodings(searchText), id: \.self) { item in
						Text(item.name)
					}
				}, header: {
					Text("All encodings")
				})
			}
			.listStyle(.sidebar)
			.listSectionSeparator(.hidden)
			.frame(minWidth: 50)

			Divider()

			DSFSearchField.SwiftUI(
				text: $searchText,
				placeholderText: "Filter",
				autosaveName: "TextEncodingListView"
			)
			.padding(4)
		}
	}
}

struct TextEncodingSelectorContentView: View {

	let fileURL: URL

	let completion: (NSApplication.ModalResponse, String.Encoding?) -> Void

	@State var selectedEncoding = TextEncodings.shared.auto
	@State var canUseEncoding = false

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text("Select a new text encoding")
				.padding(8)

			Divider()

			TextEncodingSelectorView(
				fileURL: fileURL,
				encoding: $selectedEncoding,
				canUseEncoding: $canUseEncoding
			)

			Divider()

			HStack {
				Spacer()
				Button("Use Encoding") {
					completion(.OK, selectedEncoding == .auto ? nil : selectedEncoding.value)
				}
				.disabled(!canUseEncoding)
				.keyboardShortcut(.defaultAction)
				Button("Cancel") {
					completion(.cancel, nil)
				}
			}
			.padding()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

struct FileDecodableTextView: View {

	let text: String?
	let encoding: TextEncodings.Encoding

	@Binding var canUseEncoding: Bool

	init(fileURL: URL, encoding: TextEncodings.Encoding, canUseEncoding: Binding<Bool>) {
		self.encoding = encoding
		
		let data = try! Data(fileURL: fileURL, maxByteCount: 8192)

		if encoding == .auto {
			self.text = String.decode(from: data)?.text
		}
		else {
			self.text = String(data: data, encoding: encoding.value)
		}

		_canUseEncoding = canUseEncoding
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text("Preview").font(.title3)
				.padding(4)
			Divider()
			if let text = self.text {
				MacTextEditorView(text: .constant(text))
			}
			else {
				Text("Unable to decode")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.onAppear {
			canUseEncoding = (self.text != nil)
		}
		.onChange(of: text) { value in
			canUseEncoding = value != nil
		}
	}
}

#if DEBUG

let macRoman = Bundle.main.url(forResource: "macos-roman", withExtension: "sub")!

#Preview("Encoding list") {
	TextEncodingListView(
		encoding: .constant(TextEncodings.shared.auto)
	)
	.frame(width: 300)
}

#Preview("Text encoding selector view") {
	TextEncodingSelectorView(
		fileURL: macRoman,
		encoding: .constant(TextEncodings.shared.auto),
		canUseEncoding: .constant(false)
	)
}

#Preview("Text encoding content") {
	TextEncodingSelectorContentView(fileURL: macRoman) { _, _ in }
}

#endif
