import SwiftUI
import GlideCore

struct NoteDetail: View {
    let title: String
    @Binding var text: String
    @Binding var showRawOnCursor: Bool
    
    private let gutter: CGFloat = 40
    private let gutterGap: CGFloat = 18
    
    var body: some View {
        VStack(spacing: 0) {
            noteBar
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: gutterGap) {
                    Text("#")
                        .font(Theme.mono(18))
                        .foregroundStyle(Theme.labelQuaternary)
                        .frame(width: gutter, alignment: .trailing)
                        .accessibilityHidden(true)
                    Text(title)
                        .font(Theme.display(48))
                        .tracking(-1.7)
                        .foregroundStyle(Theme.label)
                        .lineLimit(2)
                }
                
                if !counts.isEmpty {
                    Text(counts)
                        .font(Theme.mono(12))
                        .foregroundStyle(Theme.labelTertiary)
                        .padding(.leading, gutter + gutterGap)
                        .padding(.top, 8)
                }
                
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("Start writing, or type [ ] to add a task")
                            .font(Theme.ui(15))
                            .foregroundStyle(Theme.labelQuaternary)
                            .allowsHitTesting(false)
                    }
                    GlideTextView(text: $text, showRawOnCursor: showRawOnCursor)
                }
                .padding(.leading, gutter + gutterGap)
                .padding(.top, 22)
                .frame(maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: 720, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 48)
            .padding(.top, 40)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceApp)
    }
    
    private var noteBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.text")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.labelSecondary)
            Text(title)
                .font(Theme.ui(13))
                .fontWeight(.semibold)
                .foregroundStyle(Theme.label)
                .lineLimit(1)
            
            Spacer()
            
            Text("\(wordCount) words")
                .font(Theme.mono(11))
                .foregroundStyle(Theme.labelTertiary)
            
            Button {
                showRawOnCursor.toggle()
            } label: {
                Image(systemName: showRawOnCursor ? "eye.slash" : "eye")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.labelSecondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.leading, 8)
            .help(showRawOnCursor ? "Show formatted on cursor" : "Show raw on cursor")
        }
        .padding(.horizontal, 14)
        .frame(height: 42)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.separator).frame(height: 1)
        }
    }
    
    private var counts: String {
        var open = 0
        var done = 0
        for line in text.components(separatedBy: "\n") {
            if case .task(let task) = parseLine(line) {
                task.checked ? (done += 1) : (open += 1)
            }
        }
        if open == 0 && done == 0 { return "" }
        return "\(open) open · \(done) done"
    }
    
    private var wordCount: Int {
        text.split(whereSeparator: { $0.isWhitespace }).count
    }
}
