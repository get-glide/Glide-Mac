import SwiftUI
import GlideCore

struct ContentView: View {
    private let store = try! NoteStore.makeDefault()
    
    @State private var noteNames: [String] = []
    @State private var selectedNote: String = DefaultNote.today.rawValue
    @State private var noteText: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            TopBar()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
            
            HStack(spacing: 8) {
                NotebookSidebar(
                    noteNames: noteNames,
                    selectedNote: selectedNote,
                    onSelect: switchTo
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
                
                NoteDetail(title: selectedNote, text: $noteText)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
            }
        }
        .padding(12)
        .background(Theme.surfaceApp)
        .onTapGesture {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
        .onAppear {
            try? store.createDefaultNotesIfNeeded()
            noteNames = (try? store.listNotes()) ?? []
            loadNote(selectedNote)
        }
    }
    
    private func loadNote(_ name: String) {
        noteText = (try? store.read(name)) ?? ""
    }
    
    private func switchTo(_ name: String) {
        try? store.write(noteText, to: selectedNote)
        selectedNote = name
        loadNote(name)
    }
}

#Preview {
    ContentView()
}
