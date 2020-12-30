//
//  AppDelegate.swift
//  PDFMerge
//
//  Created by Matt Galloway on 30/12/2020.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow!

  func applicationDidFinishLaunching(_: Notification) {
    let contentView = ContentView()

    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.isReleasedWhenClosed = true
    window.center()
    window.setFrameAutosaveName("Main Window")
    window.title = "PDFMerge"
    window.contentView = NSHostingView(rootView: contentView)

    self.window = window
    window.makeKeyAndOrderFront(nil)
  }

  func applicationWillTerminate(_: Notification) {}

  func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
    return true
  }
}
