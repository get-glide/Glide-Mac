import SwiftUI
import GlideCore

enum Route: Hashable {
    case notebook
    case note(String)
}

struct ContentView: View {
    private let store = try! NoteStore.makeDefault()
    
    @State private var visibility: NavigationSplitViewVisibility = .all
    @State private var noteNames: [String] = []
    @State private var route: Route = .note(DefaultNote.today.rawValue)
    @State private var noteText: String = ""
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            DaySidebar(tasks: railTasks, untimedCount: untimedCount)
                .navigationSplitViewColumnWidth(min: 200, ideal: Theme.railWidth, max: 280)
        } detail: {
            detailPane
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Theme.surfaceApp)
        }
        .onTapGesture {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
        .onAppear {
            try? store.createDefaultNotesIfNeeded()
            noteNames = (try? store.listNotes()) ?? []
            if case .note(let name) = route { loadNote(name) }
        }
    }
    
    @ViewBuilder
    private var detailPane: some View {
        switch route {
        case .notebook:
            NotebookGrid(noteNames: noteNames) { name in
                openNote(name)
            }
        case .note(let name):
            NoteDetail(title: name, text: $noteText)
        }
    }
    
    private var railTasks: [RailTask] {
        noteText.components(separatedBy: "\n").compactMap { line in
            guard case .task(let task) = parseLine(line), let time = task.time else { return nil }
            return RailTask(text: task.text, time: time, checked: task.checked)
        }
    }
    
    private var untimedCount: Int {
        noteText.components(separatedBy: "\n").filter { line in
            if case .task(let task) = parseLine(line), task.time == nil, !task.checked {
                return true
            }
            return false
        }.count
    }
    
    private func loadNote(_ name: String) {
        noteText = (try? store.read(name)) ?? ""
    }
    
    private func openNote(_ name: String) {
        if case .note(let current) = route {
            try? store.write(noteText, to: current)
        }
        route = .note(name)
        loadNote(name)
    }
}

#Preview {
    ContentView()
}
