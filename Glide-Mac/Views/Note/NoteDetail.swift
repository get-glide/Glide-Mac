import SwiftUI
import GlideCore

struct NoteDetail: View {
    let title: String
    @Binding var text: String
    @Binding var showRawOnCursor: Bool
    var subject: String? = nil
    
    private var subjectColor: Color {
        guard let subject else { return Theme.labelTertiary }
        let hues: [Color] = [
            Color(hex: 0x8B96F5),
            Color(hex: 0xF0865C),
            Color(hex: 0x45C3A3),
            Color(hex: 0xF0B455),
        ]
        let index = abs(subject.hashValue) % hues.count
        return hues[index]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if let subject {
                HStack(spacing: 8) {
                    Circle()
                        .fill(subjectColor)
                        .frame(width: 6, height: 6)
                    Text(subject)
                        .font(Theme.mono(11))
                        .foregroundStyle(subjectColor)
                    Text(counts)
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.labelTertiary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 12)
            }
            
            HStack(alignment: .top, spacing: 24) {
                NoteOutline(text: text)
                    .frame(maxWidth: 140, alignment: .topLeading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 20)
                    .padding(.top, 2)
                
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Start writing, or type [ ] to add a task")
                                .font(Theme.ui(13))
                                .foregroundStyle(Theme.labelQuaternary)
                        }
                        .allowsHitTesting(false)
                    }
                    GlideTextView(text: $text, showRawOnCursor: showRawOnCursor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
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
