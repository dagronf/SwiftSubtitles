//
//  AppDelegate.swift
//  Subtitle Viewer
//
//  Created by Darren Ford on 9/5/2023.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {



	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}

	func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
		false
	}

}

