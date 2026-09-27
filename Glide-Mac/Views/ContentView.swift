import SwiftUI
import GlideCore

enum Route: Hashable {
    case notebook
    case tasks
    case note(String)
}

struct ContentView: View {
    private let store = try! NoteStore.makeDefault()
    private let summaryProvider: NotebookSummaryProviding = MockNotebookSummaries()
    private let taskAggregator: TaskAggregating = MockTaskAggregator()
    
    @State private var visibility: NavigationSplitViewVisibility = .all
    @State private var noteNames: [String] = []
    @State private var route: Route = .note(DefaultNote.today.rawValue)
    @State private var noteText: String = ""
    @State private var searchQuery: String = ""
    @State private var searchExpanded = false
    @State private var showingSettings = false
    @FocusState private var searchFocused: Bool
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            DaySidebar(tasks: railTasks, untimedCount: untimedCount)
                .navigationSplitViewColumnWidth(min: 200, ideal: Theme.railWidth, max: 280)
        } detail: {
            detailPane
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Theme.surfaceApp)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack(spacing: 10) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.label)
                    
                    Text("GLIDE")
                        .font(Theme.display(13))
                        .foregroundStyle(Theme.label)
                    
                    HStack(spacing: 4) {
                        Button {
                            route = .notebook
                        } label: {
                            Image(systemName: "book")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(width: 30, height: 30)
                                .background {
                                    if isNotebook {
                                        Capsule().fill(Theme.accent)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(isNotebook ? .white : Theme.label)
                        
                        Button {
                            route = .tasks
                        } label: {
                            Image(systemName: "checkmark.square")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(width: 30, height: 30)
                                .background {
                                    if isTasks {
                                        Capsule().fill(Theme.accent)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(isTasks ? .white : Theme.label)
                    }
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    if searchExpanded {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.label)
                        TextField("Search notes, tasks", text: $searchQuery)
                            .textFieldStyle(.plain)
                            .font(Theme.ui(12.5))
                            .foregroundStyle(Theme.label)
                            .focused($searchFocused)
                            .frame(width: 170)
                            .onExitCommand {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    searchExpanded = false
                                    searchQuery = ""
                                }
                            }
                    } else {
                        Button {
                            searchExpanded = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                searchFocused = true
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.label)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.label)
                            .frame(width: 26, height: 26)
                    }
                    .buttonStyle(.plain)
                }
                .onChange(of: searchFocused) { _, isFocused in
                    if !isFocused && searchExpanded {
                        withAnimation(.easeOut(duration: 0.18)) {
                            searchExpanded = false
                            searchQuery = ""
                        }
                    }
                }
            }
        }
        .overlay {
            if showingSettings {
                ZStack {
                    Color.black.opacity(0.3)
                        .onTapGesture { withAnimation(.easeOut(duration: 0.2)) { showingSettings = false } }
                    SettingsView(onClose: { withAnimation(.easeOut(duration: 0.2)) { showingSettings = false } })
                        .frame(width: 380, height: 480)
                }
            }
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
    
    private var isNotebook: Bool {
        if case .notebook = route { return true }
        return false
    }
    
    private var isTasks: Bool {
        if case .tasks = route { return true }
        return false
    }
    
    @ViewBuilder
    private var detailPane: some View {
        switch route {
        case .notebook:
            NotebookGrid(entries: summaryProvider.summaries()) { name in
                openNote(name)
            }
        case .tasks:
            TasksPage(tasks: taskAggregator.allTasks()) { name in
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
