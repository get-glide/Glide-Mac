import SwiftUI
import GlideCore

enum Route: Hashable {
    case folder
    case tasks
    case note(String)
}

struct ContentView: View {
    private let store: NoteStore
    @StateObject private var taskPanel: TaskPanelViewModel
    @State private var sidebarRange: SidebarRange = .today
    @State private var sidebarSource: TaskSource = .currentNote(name: DefaultNote.today.rawValue)
    @State private var visibility: NavigationSplitViewVisibility = .all
    @State private var noteNames: [String] = []
    @State private var route: Route = .note(DefaultNote.today.rawValue)
    @State private var showRawOnCursor: Bool = true
    @State private var noteText: String = ""
    @State private var searchQuery: String = ""
    @State private var searchExpanded = false
    @State private var showingSettings = false
    @FocusState private var searchFocused: Bool

    init() {
        let store = try! NoteStore.makeDefault()
        self.store = store
        _taskPanel = StateObject(wrappedValue: TaskPanelViewModel(store: store))
        FontLoader.registerFonts()
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            TaskSidebar(
                groups: taskPanel.groups,
                noDueDateTasks: taskPanel.noDueDateTasks,
                currentNoteName: {
                    if case .note(let name) = route { return name }
                    return DefaultNote.today.rawValue
                }(),
                range: $sidebarRange,
                source: $sidebarSource
            )
                .navigationSplitViewColumnWidth(min: 200, ideal: Theme.railWidth, max: 280)
        } detail: {
            detailPane
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Theme.surfaceApp)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.label)
                    
                    Text("GLIDE")
                        .font(Theme.display(13))
                        .foregroundStyle(Theme.label)
                    
                    HStack(spacing: 4) {
                        Button {
                            route = .folder
                        } label: {
                            Image(systemName: "book")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(width: 30, height: 30)
                                .background {
                                    if isFolder {
                                        Capsule().fill(Theme.accent)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(isFolder ? .white : Theme.label)
                        
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
                .padding(.horizontal, 8)
            }
            
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 8) {
                    if searchExpanded {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .semibold))
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
                                .font(.system(size: 15, weight: .semibold))
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
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
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
        .onChange(of: noteText) { _, newText in
            if case .note(let name) = route {
                taskPanel.update(
                    lines: newText.components(separatedBy: "\n"),
                    noteName: name
                )
            }
        }
        .onChange(of: sidebarRange) { _, newRange in
            switch newRange {
                case .today: taskPanel.scope = .today
                case .week: taskPanel.scope = .thisWeek
                case .month: taskPanel.scope = .thisMonth
            }
        }
        .onChange(of: sidebarSource) { _, newSource in
            taskPanel.source = newSource
        }
    }
    
    private var isFolder: Bool {
        if case .folder = route { return true }
        return false
    }
    
    private var isTasks: Bool {
        if case .tasks = route { return true }
        return false
    }
    
    @ViewBuilder
    private var detailPane: some View {
        switch route {
        case .folder:
            FolderGrid(notes: folderNotes) { name in
                openNote(name)
            }
        case .tasks:
            TasksPage(tasks: allNoteTasks) { name in
                openNote(name)
            }
        case .note(let name):
            NoteDetail(
                title: name,
                text: $noteText,
                showRawOnCursor: $showRawOnCursor,
                subject: DefaultNote.allCases.map { $0.rawValue }.contains(name) ? nil : name
            )
            .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showRawOnCursor.toggle()
                        } label: {
                            Image(systemName: showRawOnCursor ? "eye.slash" : "eye")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.label)
                        }
                        .buttonStyle(.plain)
                        .help(showRawOnCursor ? "Show formatted on cursor" : "Show raw on cursor")
                    }
                }
        }
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
        
        if case .currentNote = sidebarSource {
            sidebarSource = .currentNote(name: name)
            taskPanel.source = sidebarSource
        }
    }
    
    private var folderNotes: [(name: String, open: Int, done: Int)] {
        if case .note(let name) = route {
            try? store.write(noteText, to: name)
        }
        
        let names = (try? store.listNotes()) ?? []
        return names.map { name in
            let text = (try? store.read(name)) ?? ""
            let lines = text.components(separatedBy: "\n")
            let tasks = fetchTasks(lines: lines, noteName: name)
            let open = tasks.filter { !$0.task.checked }.count
            let done = tasks.filter { $0.task.checked }.count
            return (name: name, open: open, done: done)
        }
    }

    private var allNoteTasks: [NoteTask] {
        if case .note(let name) = route {
            try? store.write(noteText, to: name)
        }
        let names = (try? store.listNotes()) ?? []
        return names.flatMap { name in
            let text = (try? store.read(name)) ?? ""
            let lines = text.components(separatedBy: "\n")
            return fetchTasks(lines: lines, noteName: name)
        }
    }
}

#Preview {
    ContentView()
}
