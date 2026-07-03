//
//  GlideTextView.swift
//  Glide-Mac
//
//  Created by Pranay Venkat Aluri on 7/2/26.
//

import SwiftUI
import AppKit

struct GlideTextView: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.string = text
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.backgroundColor = .clear
        textView.drawsBackground = trueC
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

        // Guard against the feedback-loop problem mentioned earlier:
        // only push `text` into the NSTextView if it's actually different
        // from what's already there. Without this check, every call to
        // updateNSView would reset the text view's content — and once we
        // add the Coordinator in step 2, that would fight with the user's
        // own typing and reset their cursor position constantly.
        if textView.string != text {
            textView.string = text
        }
    }
}
