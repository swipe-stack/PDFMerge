//
//  ContentView.swift
//  PDFMerge
//
//  Created by Matt Galloway on 30/12/2020.
//

import Quartz
import SwiftUI

struct ContentView: View {
  @State private var frontFileURL: URL?
  @State private var backFileURL: URL?
  @State private var backPagesOppositeOrder = true

  private func chooseFile(handler: @escaping (_ url: URL) -> Void) {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.begin { [unowned panel] result in
      switch result {
      case .OK:
        if let url = panel.url {
          handler(url)
        }
      default:
        break
      }
    }
  }

  private func chooseFrontFile() {
    self.chooseFile { (url) -> Void in
      self.frontFileURL = url
    }
  }

  private func chooseBackFile() {
    self.chooseFile { (url) -> Void in
      self.backFileURL = url
    }
  }

  private func performMerge() {
    guard let frontFileURL = self.frontFileURL, let backFileURL = self.backFileURL else {
      let alert = NSAlert()
      alert.addButton(withTitle: "OK")
      alert.messageText = "Please select both a front and back file."
      alert.alertStyle = .warning
      alert.beginSheetModal(for: NSApp.keyWindow!, completionHandler: nil)
      return
    }

    guard
      let frontPDF = PDFDocument(url: frontFileURL as URL),
      let backPDF = PDFDocument(url: backFileURL as URL) else {
      let alert = NSAlert()
      alert.addButton(withTitle: "OK")
      alert.messageText = "Failed to open PDFs."
      alert.alertStyle = .warning
      alert.beginSheetModal(for: NSApp.keyWindow!, completionHandler: nil)
      return
    }

    guard
      frontPDF.pageCount == backPDF.pageCount else {
      let alert = NSAlert()
      alert.addButton(withTitle: "OK")
      alert.messageText = "Page counts of front (\(frontPDF.pageCount)) and back (\(backPDF.pageCount)) don't match."
      alert.alertStyle = .warning
      alert.beginSheetModal(for: NSApp.keyWindow!, completionHandler: nil)
      return
    }

    let outPDF = PDFDocument()

    let pageCount = frontPDF.pageCount
    for pageIndex in 0 ..< pageCount {
      let frontIndex = pageIndex
      let backIndex = self.backPagesOppositeOrder ? pageCount - pageIndex - 1 : pageIndex
      if let frontPage = frontPDF.page(at: frontIndex),
        let backPage = backPDF.page(at: backIndex) {
        outPDF.insert(frontPage, at: pageIndex * 2)
        outPDF.insert(backPage, at: pageIndex * 2 + 1)
      }
    }

    let panel = NSSavePanel()
    panel.allowedFileTypes = ["pdf"]
    panel.allowsOtherFileTypes = false
    panel.beginSheetModal(for: NSApp.keyWindow!) { result in
      switch result {
      case .OK:
        if let url = panel.url {
          outPDF.write(to: url)
        }
      default:
        break
      }
    }
  }

  var body: some View {
    VStack {
      GroupBox(label: Text("Front pages")) {
        HStack {
          Text(self.frontFileURL?.lastPathComponent ?? "Choose file")
            .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)

          Button("Select file") {
            self.chooseFrontFile()
          }
        }
        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        .frame(maxWidth: .infinity)
      }
      .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
        if let item = providers.first {
          item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { urlData, _ in
            DispatchQueue.main.async {
              if let urlData = urlData as? Data {
                self.frontFileURL = URL(dataRepresentation: urlData, relativeTo: nil)
              }
            }
          }
          return true
        }
        return false
      }

      Spacer()
        .frame(height: 20)

      GroupBox(label: Text("Back pages")) {
        HStack {
          Text(self.backFileURL?.lastPathComponent ?? "Choose file")
            .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)

          Button("Select file") {
            self.chooseBackFile()
          }
        }
        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        .frame(maxWidth: .infinity)
      }
      .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
        if let item = providers.first {
          item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { urlData, _ in
            DispatchQueue.main.async {
              if let urlData = urlData as? Data {
                self.backFileURL = URL(dataRepresentation: urlData, relativeTo: nil)
              }
            }
          }
          return true
        }
        return false
      }

      Spacer()
        .frame(height: 20)

      GroupBox(label: Text("Options")) {
        VStack(alignment: .leading) {
          HStack {
            Toggle(isOn: $backPagesOppositeOrder) {
              Text("Back pages in reverse order?")
            }
          }
        }
        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      Spacer()
        .frame(height: 20)

      Button("Merge") {
        self.performMerge()
      }
    }
    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView()
    }
  }
}
