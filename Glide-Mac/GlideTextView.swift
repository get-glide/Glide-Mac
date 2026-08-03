//
//  GlideTextView.swift
//  Glide-Mac
//
//  Created by Pranay Venkat Aluri on 7/2/26.
//

import SwiftUI
import AppKit
import GlideCore
 
struct GlideTextView: NSViewRepresentable {
    @Binding var text: String
 
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
 
    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.string = text
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.backgroundColor = .clear
        textView.drawsBackground = true
        textView.delegate = context.coordinator
 
        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
 
        return scrollView
    }
 
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        guard !context.coordinator.isUserEditing else { return }
 
        if textView.string != text {
            textView.string = text
        }
    }
 
 
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: GlideTextView
        var isUserEditing: Bool = false
        var isApplyingStyling: Bool = false
        var cachedLines: [String] = []
        var parsedLines: [ParsedLine] = []
 
        init(parent: GlideTextView) {
            self.parent = parent
        }
 
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
 
            isUserEditing = true
            
            let currentLines = textView.string.components(separatedBy: "\n")
            var changedLineIndex: Int? = nil
 
            for i in 0..<max(currentLines.count, cachedLines.count) {
                let currentLine = i < currentLines.count ? currentLines[i] : nil
                let cachedLine  = i < cachedLines.count  ? cachedLines[i]   : nil
 
                if currentLine != cachedLine {
                    changedLineIndex = i
                    break
                }
            }
 
            cachedLines = currentLines
            while parsedLines.count < currentLines.count {
                parsedLines.append(.note(text: "", headingLevel: nil))
            }
            while parsedLines.count > currentLines.count {
                parsedLines.removeLast()
            }
 
            if let index = changedLineIndex {
                let changedLineText = index < currentLines.count ? currentLines[index] : ""
                let result = parseLine(changedLineText)
                parsedLines[index] = result
                
                if needsCreatedDate(line: changedLineText) {
                    let lineWithDate = appendCreatedDate(line: changedLineText)
                    
                    let precedingText = cachedLines[..<index].joined(separator: "\n")
                    let lineStart = precedingText.isEmpty ? 0 : precedingText.count + 1
                    let lineRange = (textView.string as NSString).lineRange(for: NSRange(location: lineStart, length: 0))
                    
                    isApplyingStyling = true
                    textView.textStorage?.beginEditing()
                    textView.textStorage?.replaceCharacters(in: lineRange, with: lineWithDate)
                    textView.textStorage?.endEditing()
                    isApplyingStyling = false
                    
                    cachedLines[index] = lineWithDate
                    parsedLines[index] = parseLine(lineWithDate)
                    parent.text = textView.string
                }
                
                print(parsedLines[index])
            }
 
            isUserEditing = false
        }
    }
}
