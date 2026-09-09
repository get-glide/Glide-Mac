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
        
        if textView.string != text {
            textView.string = text
            context.coordinator.restyle(textView)
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: GlideTextView
        var isUserEditing: Bool = false
        
        init(parent: GlideTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            isUserEditing = true
            parent.text = textView.string
            restyle(textView)
            isUserEditing = false
        }
        
        func restyle(_ textView: NSTextView) {
            guard let storage = textView.textStorage else { return }
            let selected = textView.selectedRanges
            
            let full = storage.string as NSString
            var location = 0
            
            storage.beginEditing()
            full.enumerateSubstrings(in: NSRange(location: 0, length: full.length),
                                     options: [.byLines, .substringNotRequired]) { _, range, enclosingRange, _ in
                let lineText = full.substring(with: enclosingRange)
                let parsed = parseLine(lineText)
                self.apply(parsed, to: enclosingRange, in: storage)
                location = enclosingRange.location + enclosingRange.length
            }
            storage.endEditing()
            
            textView.selectedRanges = selected
        }
        
        private func apply(_ line: ParsedLine, to range: NSRange, in storage: NSTextStorage) {
            guard range.length > 0 else { return }
            
            switch line {
            case .task(let task):
                let font = NSFont.monospacedSystemFont(ofSize: 13.5, weight: .regular)
                let color = task.checked ? NSColor(Theme.labelTertiary) : NSColor(Theme.label)
                storage.addAttribute(.font, value: font, range: range)
                storage.addAttribute(.foregroundColor, value: color, range: range)
                
            case .note(_, let headingLevel):
                if let level = headingLevel {
                    let size: CGFloat = level == 1 ? 20 : level == 2 ? 15 : 13.5
                    storage.addAttribute(.font, value: NSFont(name: "Hanken Grotesk", size: size)
                                         ?? .systemFont(ofSize: size), range: range)
                    storage.addAttribute(.foregroundColor, value: NSColor(Theme.label), range: range)
                } else {
                    storage.addAttribute(.font, value: NSFont(name: "Hanken Grotesk", size: 14.5)
                                         ?? .systemFont(ofSize: 14.5), range: range)
                    storage.addAttribute(.foregroundColor, value: NSColor(Theme.prose), range: range)
                }
            }
        }
    }
}
