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
    
    var showRawOnCursor: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.string = text
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textColor = NSColor(Theme.label)
        textView.insertionPointColor = NSColor(Theme.label)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = true
        textView.allowsUndo = true
        textView.drawsBackground = false
        textView.delegate = context.coordinator
        
        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        context.coordinator.restyle(textView)
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        guard !context.coordinator.isUserEditing else { return }
        
        let rawChanged = context.coordinator.showRawOnCursor != showRawOnCursor
        context.coordinator.showRawOnCursor = showRawOnCursor
        
        if textView.string != text {
            textView.string = text
            context.coordinator.restyle(textView)
        } else if rawChanged {
            context.coordinator.restyle(textView)
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: GlideTextView
        var isUserEditing: Bool = false
        var isApplyingStyling: Bool = false
        var cachedLines: [String] = []
        var parsedLines: [ParsedLine] = []
        var cursorLineIndex: Int? = nil
        var showRawOnCursor: Bool = true

        init(parent: GlideTextView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            guard !isApplyingStyling else { return }

            isUserEditing = true
            parent.text = textView.string

            let currentLines = textView.string.components(separatedBy: "\n")
            var changedLineIndex: Int? = nil

            for i in 0..<max(currentLines.count, cachedLines.count) {
                let currentLine = i < currentLines.count ? currentLines[i] : nil
                let cachedLine = i < cachedLines.count ? cachedLines[i] : nil
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
                guard index < currentLines.count else {
                    restyle(textView)
                    isUserEditing = false
                    return
                }
                
                let changedLineText = currentLines[index]
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

                let currentLineText = cachedLines[index]
                if needsDueDate(line: currentLineText) {
                    let lineWithDue = appendDueDate(line: currentLineText)

                    let precedingText = cachedLines[..<index].joined(separator: "\n")
                    let lineStart = precedingText.isEmpty ? 0 : precedingText.count + 1
                    let lineRange = (textView.string as NSString).lineRange(for: NSRange(location: lineStart, length: 0))

                    isApplyingStyling = true
                    textView.textStorage?.beginEditing()
                    textView.textStorage?.replaceCharacters(in: lineRange, with: lineWithDue)
                    textView.textStorage?.endEditing()
                    isApplyingStyling = false

                    cachedLines[index] = lineWithDue
                    parsedLines[index] = parseLine(lineWithDue)
                    parent.text = textView.string
                }

                print(parsedLines[index])
            }

            restyle(textView)
            isUserEditing = false
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let location = textView.selectedRange().location
            let lines = textView.string.components(separatedBy: "\n")
            var charCount = 0
            for (i, line) in lines.enumerated() {
                charCount += line.count + 1
                if location < charCount {
                    cursorLineIndex = i
                    break
                }
            }
            restyle(textView)
        }

        var isRestyling: Bool = false

        func restyle(_ textView: NSTextView) {
            guard !isApplyingStyling else { return }
            guard !isRestyling else { return }
            guard let storage = textView.textStorage else { return }
            
            isRestyling = true
            let selected = textView.selectedRanges
            let snapshot = storage.string as NSString
            let snapshotLength = snapshot.length

            storage.beginEditing()
            var lineIndex = 0
            snapshot.enumerateSubstrings(
                in: NSRange(location: 0, length: snapshotLength),
                options: [.byLines, .substringNotRequired]
            ) { _, _, enclosingRange, _ in
                guard enclosingRange.location + enclosingRange.length <= snapshotLength else { return }
                let isCursorLine = lineIndex == self.cursorLineIndex
                let lineText = snapshot.substring(with: enclosingRange)
                let parsed = parseLine(lineText)
                self.apply(parsed, to: enclosingRange, in: storage, isCursorLine: isCursorLine)
                lineIndex += 1
            }
            storage.endEditing()

            textView.selectedRanges = selected
            isRestyling = false
        }

        private func apply(_ line: ParsedLine, to range: NSRange, in storage: NSTextStorage,  isCursorLine: Bool) {
            guard range.length > 0 else { return }
            
            if isCursorLine && showRawOnCursor {
                storage.setAttributes([
                    .foregroundColor: NSColor(Theme.label),
                    .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
                ], range: range)
                return
            }

            switch line {
            case .task(let task):
                let color = task.checked ? NSColor(Theme.labelTertiary) : NSColor(Theme.label)
                storage.addAttribute(.foregroundColor, value: color, range: range)
                storage.addAttribute(.backgroundColor, value: NSColor(Theme.surfaceTile), range: range)

                let paragraph = NSMutableParagraphStyle()
                paragraph.paragraphSpacingBefore = 4
                paragraph.paragraphSpacing = 4
                storage.addAttribute(.paragraphStyle, value: paragraph, range: range)

            case .note(_, let headingLevel):
                storage.addAttribute(.foregroundColor, value: NSColor(Theme.prose), range: range)
                let paragraph = NSMutableParagraphStyle()
                paragraph.paragraphSpacingBefore = headingLevel != nil ? 12 : 6
                paragraph.paragraphSpacing = 6
                storage.addAttribute(.paragraphStyle, value: paragraph, range: range)
            }
        }
    }
}
