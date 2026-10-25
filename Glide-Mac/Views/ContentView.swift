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
    @State private var sidebarRange: SidebarRange = .week
    @State private var sidebarSource: TaskSource = .currentNote(name: DefaultNote.today.rawValue)
    @State private var noteNames: [String] = []
    @State private var route: Route = .note(DefaultNote.today.rawValue)
    @State private var showRawOnCursor = true
    @State private var noteText = ""
    @State private var searchQuery = ""
    @State private var searchExpanded = false
    @State private var showingSettings = false
    @State private var showingNewNote = false
    @FocusState private var searchFocused: Bool
    @State private var openTabs = [DefaultNote.today.rawValue]
    @State private var layout = TimelineLayout()
    
    init() {
        let store = try! NoteStore.makeDefault()
        self.store = store
        _taskPanel = StateObject(wrappedValue: TaskPanelViewModel(store: store))
        FontLoader.registerFonts()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                layout: layout,
                route: route,
                openTabs: openTabs,
                onRoute: { route = $0 },
                onSelectTab: openNote,
                onCloseTab: closeTab,
                onToggleSidebar: { withAnimation(.snappy(duration: 0.25)) { layout.visible.toggle() } },
                onNewNote: { reloadNoteNames(); showingNewNote = true },
                onQuickOpen: openQuickOpen,
                onSettings: { setSettings(!showingSettings) }
            )
            
            HStack(spacing: 0) {
                if layout.visible {
                    TimelineColumn(layout: layout) {
                        TaskSidebar(
                            groups: taskPanel.groups,
                            noDueDateTasks: taskPanel.noDueDateTasks,
                            currentNoteName: currentNoteName,
                            upNext: upNext,
                            range: $sidebarRange,
                            source: $sidebarSource,
                            onOpen: openNote
                        )
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    
                    ResizeHandle(layout: layout)
                        .transition(.opacity)
                }
                
                detailPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(Theme.surfaceApp)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.leading, layout.visible ? 0 : 10)
            .padding([.trailing, .bottom], 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.chrome)
        .background(TrafficLights())
        .ignoresSafeArea(.container, edges: .top)
        .preferredColorScheme(.dark)
        .overlay {
            if searchExpanded {
                QuickOpen(query: $searchQuery, results: quickResults, openTabs: openTabs,
                          focus: $searchFocused, onPick: pickQuickResult, onClose: closeQuickOpen)
            }
        }
        .overlay {
            if showingNewNote {
                NewNotePanel(existing: noteNames, onCreate: createNote, onClose: { showingNewNote = false })
            }
        }
        .overlay {
            if showingSettings {
                SettingsView(folder: store.directory, onClose: { setSettings(false) })
            }
        }
        .onTapGesture {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
        .onAppear {
            try? store.createDefaultNotesIfNeeded()
            reloadNoteNames()
            loadNote(currentNoteName)
            taskPanel.scope = sidebarRange.scope
        }
        .onChange(of: noteText) { _, newText in
            guard case .note(let name) = route else { return }
            taskPanel.update(lines: newText.components(separatedBy: "\n"), noteName: name)
        }
        .onChange(of: sidebarRange) { taskPanel.scope = $1.scope }
        .onChange(of: sidebarSource) { taskPanel.source = $1 }
    }
    
    private var currentNoteName: String {
        if case .note(let name) = route { return name }
        return DefaultNote.today.rawValue
    }
    
    private var upNext: NoteTask? {
        currentTask(from: taskPanel.groups.flatMap(\.tasks).filter {
            $0.task.dueDate.map(Calendar.current.isDateInToday) ?? false
        })
    }
    
    @ViewBuilder
    private var detailPane: some View {
        switch route {
        case .folder:
            FolderGrid(notes: folderNotes, onOpen: openNote)
        case .tasks:
            TasksPage(tasks: allNoteTasks, onOpen: openNote)
        case .note(let name):
            NoteDetail(title: name, text: $noteText, showRawOnCursor: $showRawOnCursor)
        }
    }
    
    private var quickResults: [QuickOpenResult] {
        let query = searchQuery.trimmingCharacters(in: .whitespaces)
        let names = noteNames
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            .filter { query.isEmpty || $0.localizedCaseInsensitiveContains(query) }
            .map { QuickOpenResult(noteName: $0, line: nil) }
        guard !query.isEmpty else { return names }
        return names + ((try? store.search(query)) ?? []).map { QuickOpenResult(noteName: $0.noteName, line: $0.line) }
    }
    
    private var folderNotes: [(name: String, open: Int, done: Int)] {
        saveCurrentNote()
        return ((try? store.listNotes()) ?? []).map { name in
            let tasks = tasks(in: name)
            let done = tasks.filter(\.task.checked).count
            return (name: name, open: tasks.count - done, done: done)
        }
    }
    
    private var allNoteTasks: [NoteTask] {
        saveCurrentNote()
        return ((try? store.listNotes()) ?? []).flatMap(tasks(in:))
    }
    
    private func tasks(in name: String) -> [NoteTask] {
        fetchTasks(lines: ((try? store.read(name)) ?? "").components(separatedBy: "\n"), noteName: name)
    }
    
    private func saveCurrentNote() {
        if case .note(let name) = route {
            try? store.write(noteText, to: name)
        }
    }
    
    private func reloadNoteNames() {
        noteNames = (try? store.listNotes()) ?? []
    }
    
    private func loadNote(_ name: String) {
        noteText = (try? store.read(name)) ?? ""
    }
    
    private func setSettings(_ open: Bool) {
        withAnimation(.easeOut(duration: 0.2)) { showingSettings = open }
    }
    
    private func createNote(_ name: String) -> Bool {
        guard (try? store.write("", to: name)) != nil else { return false }
        reloadNoteNames()
        showingNewNote = false
        openNote(name)
        return true
    }
    
    private func openQuickOpen() {
        saveCurrentNote()
        reloadNoteNames()
        searchQuery = ""
        searchExpanded = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { searchFocused = true }
    }
    
    private func closeQuickOpen() {
        searchExpanded = false
        searchQuery = ""
    }
    
    private func pickQuickResult(_ name: String) {
        closeQuickOpen()
        openNote(name)
    }
    
    private func closeTab(_ name: String) {
        guard let index = openTabs.firstIndex(of: name) else { return }
        let wasActive = route == .note(name)
        openTabs.remove(at: index)
        guard wasActive else { return }
        
        if openTabs.isEmpty {
            saveCurrentNote()
            route = .folder
        } else {
            openNote(openTabs[max(0, index - 1)])
        }
    }
    
    private func openNote(_ name: String) {
        saveCurrentNote()
        if !openTabs.contains(name) {
            openTabs.append(name)
        }
        route = .note(name)
        loadNote(name)
        
        if case .currentNote = sidebarSource {
            sidebarSource = .currentNote(name: name)
            taskPanel.source = sidebarSource
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 1280, height: 820)
}
