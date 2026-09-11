import SwiftUI
import GlideCore

struct NoteDetail: View {
    let title: String
    @Binding var text: String
    
    var subject: String? = "cs 2110"
    
    @State private var showingSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 12) {
                Text(title)
                    .font(Theme.ui(14))
                    .foregroundStyle(Theme.label)
                
                if let subject {
                    Text(subject)
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.labelTertiary)
                }
                
                Text(counts)
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.labelTertiary)
                
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.labelQuaternary)
                    .pressable { }
                
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .foregroundStyle(Theme.labelQuaternary)
                }
                .buttonStyle(PressableButtonStyle())
            }
            .frame(height: Theme.barHeight)
            .padding(.horizontal, 16)
            
            HStack(alignment: .top, spacing: 10) {
                NoteOutline(items: MockOutline.items)
                
                GlideTextView(text: $text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceApp)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
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
}
