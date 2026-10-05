//
//  MiniNoteView.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/4/26.
//


import SwiftUI
import GlideCore

// One note in the mini window, typeable with the same `GlideTextView` as the
// main editor, so styling and parsing match exactly.


struct MiniNoteView: View {
    let title: String
    @Binding var text: String
    
    // Task counts for the footer, using Core's parser so they match the main window.
    private var counts: (open: Int, done: Int) {
        var open = 0, done = 0
        for line in text.components(separatedBy: "\n") {
            if case .task(let task) = parseLine(line) { task.checked ? (done += 1) : (open += 1) }
        }
        return (open, done)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(Theme.display(26))
                .foregroundStyle(MiniStyle.text)
                .lineLimit(2)
                .padding(.horizontal, 4)
                .padding(.bottom, 10)
            
            GlideTextView(text: $text, showRawOnCursor: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1)
            HStack {
                // Hidden entirely when the note has no tasks, instead of showing "0 open".
                if counts.open + counts.done > 0 {
                    Text("\(counts.open) open · \(counts.done) done")
                }
                Spacer()
            }
            .font(Theme.mono(11))
            .foregroundStyle(MiniStyle.textFaint)
            .padding(.horizontal, 4)
            .padding(.top, 10)
        }
    }
}
