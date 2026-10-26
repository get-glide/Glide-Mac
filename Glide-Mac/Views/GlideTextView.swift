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
        context.coordinator.cachedLines = text.components(separatedBy: "\n")
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
        let c = context.coordinator
        guard !c.isUserEditing else { return }

        let rawChanged = c.showRawOnCursor != showRawOnCursor
        c.showRawOnCursor = showRawOnCursor

        if textView.string != text {
            c.isLoadingText = true
            textView.string = text
            c.cachedLines = text.components(separatedBy: "\n")
            c.parsedLines = []
            c.cursorLineIndex = 0
            c.isLoadingText = false
            c.restyle(textView)
        } else if rawChanged {
            c.restyle(textView)
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: GlideTextView
        var isUserEditing: Bool = false
        var isApplyingStyling: Bool = false
        var isLoadingText = false
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
                parsedLines[index] = parseLine(changedLineText)

                let finalized = finalizeLine(changedLineText)
                if finalized != changedLineText {
                    applyLineEdit(index: index, old: changedLineText, new: finalized, in: textView, lines: currentLines)
                    cachedLines[index] = finalized
                    parsedLines[index] = parseLine(finalized)
                    parent.text = textView.string
                }
            }

            restyle(textView)
            isUserEditing = false
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            guard !isApplyingStyling, !isRestyling, !isLoadingText else { return }
            let location = textView.selectedRange().location
            let lines = textView.string.components(separatedBy: "\n")
            var charCount = 0
            let ns = textView.string as NSString
            let before = ns.substring(to: min(location, ns.length))
            cursorLineIndex = before.components(separatedBy: "\n").count - 1
            restyle(textView)
        }
        
        private func hideCreatedTag(in lineText: String, lineRange: NSRange, storage: NSTextStorage) {
            let ns = lineText as NSString
            guard let regex = try? NSRegularExpression(pattern: #"\s*@created\(\d{4}-\d{2}-\d{2}\)"#) else { return }
            for match in regex.matches(in: lineText, range: NSRange(location: 0, length: ns.length)) {
                let range = NSRange(location: lineRange.location + match.range.location, length: match.range.length)
                guard range.location + range.length <= storage.length else { continue }
                storage.addAttributes([
                    .foregroundColor: NSColor.clear,
                    .font: NSFont.systemFont(ofSize: 0.01)
                ], range: range)
            }
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
                self.hideCreatedTag(in: lineText, lineRange: enclosingRange, storage: storage)
                lineIndex += 1
            }
            storage.endEditing()

            textView.selectedRanges = selected
            isRestyling = false
        }
        
        private func contentRange(ofLine index: Int, in lines: [String]) -> NSRange {
            var location = 0
            for i in 0..<index {
                location += (lines[i] as NSString).length + 1
            }
            return NSRange(location: location, length: (lines[index] as NSString).length)
        }
        
        private func applyLineEdit(index: Int, old: String, new: String, in textView: NSTextView, lines: [String]) {
            let lineRange = contentRange(ofLine: index, in: lines)
            let oldNS = old as NSString
            let newNS = new as NSString
            
            var prefix = 0
            let limit = min(oldNS.length, newNS.length)
            while prefix < limit, oldNS.character(at: prefix) == newNS.character(at: prefix) {
                prefix += 1
            }
            var suffix = 0
            while suffix < limit - prefix,
                oldNS.character(at: oldNS.length - 1 - suffix) == newNS.character(at: newNS.length - 1 - suffix) {
                suffix += 1
            }
            
            let oldChanged = NSRange(location: lineRange.location + prefix,
                                     length: oldNS.length - prefix - suffix)
            let replacement = newNS.substring(with: NSRange(location: prefix,
                                                           length: newNS.length - prefix - suffix))
            
            let selection = textView.selectedRange()
            var cursor = selection.location
            if cursor > oldChanged.location + oldChanged.length {
                cursor += (replacement as NSString).length - oldChanged.length
            }
            
            isApplyingStyling = true
            textView.textStorage?.beginEditing()
            textView.textStorage?.replaceCharacters(in: oldChanged, with: replacement)
            textView.textStorage?.endEditing()
            isApplyingStyling = false
            
            let total = (textView.string as NSString).length
            textView.setSelectedRange(NSRange(location: max(0, min(cursor, total)), length: selection.length))
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
                storage.removeAttribute(.backgroundColor, range: range)
                storage.addAttribute(.foregroundColor, value: NSColor(Theme.prose), range: range)
                let paragraph = NSMutableParagraphStyle()
                paragraph.paragraphSpacingBefore = headingLevel != nil ? 12 : 6
                paragraph.paragraphSpacing = 6
                storage.addAttribute(.paragraphStyle, value: paragraph, range: range)
            }
        }
    }
}
