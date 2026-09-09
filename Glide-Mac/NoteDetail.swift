import SwiftUI
import GlideCore

struct NoteDetail: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Top bar, 36pt, matches the sidebar header
            HStack(spacing: 12) {
                Text(title)
                    .font(Theme.ui(14))
                    .foregroundStyle(Theme.label)
                
                Text(counts)
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.labelTertiary)
                
                Spacer()
            }
            .frame(height: Theme.barHeight)
            .padding(.horizontal, 16)
            
            GlideTextView(text: $text)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceApp)
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
}
