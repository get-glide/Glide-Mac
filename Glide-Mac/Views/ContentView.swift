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
    @State private var showRawOnCursor: Bool = true
    @State private var noteText: String = ""
    @State private var searchQuery: String = ""
    @State private var searchExpanded = false
    @State private var showingSettings = false
    @State private var showingNewNote = false
    @FocusState private var searchFocused: Bool
    @State private var openTabs = [DefaultNote.today.rawValue]
    @State private var layout = TimelineLayout()
    @State private var activeNoteName = DefaultNote.today.rawValue
    @State private var loadedText = ""
    @State private var refreshTick = 0
    
    init() {
        let store = try! NoteStore.makeDefault()
        self.store = store
        _taskPanel = StateObject(wrappedValue: TaskPanelViewModel(store: store, scope: .anyDate))
        FontLoader.registerFonts()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                layout: layout,
                route: route,
                openTabs: openTabs,
                onRoute: { saveIfDirty(); route = $0 },
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
                            currentNoteName: activeNoteName,
                            upNext: upNext,
                            range: $sidebarRange,
                            source: $sidebarSource,
                            onOpen: openNote,
                            onToggle: toggle
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
            noteNames = (try? store.listNotes()) ?? []
            loadNote(activeNoteName)
            taskPanel.scope = sidebarRange.scope
        }
        .onChange(of: noteText) { _, newText in
            taskPanel.update(lines: newText.components(separatedBy: "\n"), noteName: activeNoteName)
        }
        .onChange(of: sidebarRange) { taskPanel.scope = $1.scope }
        .onChange(of: sidebarSource) { taskPanel.source = $1 }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in syncFromDisk() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in syncFromDisk() }
        .onReceive(NotificationCenter.default.publisher(for: .glideSaveNow)) { _ in saveIfDirty() }
        .onReceive(NotificationCenter.default.publisher(for: .glideReloadNow)) { _ in loadNote(activeNoteName) }
        .onDisappear { saveIfDirty() }
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
    
    private func tasks(in name: String) -> [NoteTask] {
        let text = (name == activeNoteName) ? noteText : ((try? store.read(name)) ?? "")
        return fetchTasks(lines: text.components(separatedBy: "\n"), noteName: name)
    }

    private var folderNotes: [(name: String, open: Int, done: Int)] {
        _ = refreshTick
        return ((try? store.listNotes()) ?? []).map { name in
            let items = tasks(in: name).filter(\.task.hasCheckbox)
            let done = items.filter(\.task.checked).count
            return (name: name, open: items.count - done, done: done)
        }
    }

    private var allNoteTasks: [NoteTask] {
        _ = refreshTick
        return ((try? store.listNotes()) ?? []).flatMap(tasks(in:))
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
        activeNoteName = name
        let text = (try? store.read(name)) ?? ""
        noteText = text
        loadedText = text
        taskPanel.update(lines: text.components(separatedBy: "\n"), noteName: name)
    }

    private func saveIfDirty() {
        guard noteText != loadedText else { return }
        do {
            try store.write(noteText, to: activeNoteName)
            loadedText = noteText
        } catch {
            print("save failed: \(error)")
        }
    }

    private func openNote(_ name: String) {
        saveIfDirty()
        if !openTabs.contains(name) { openTabs.append(name) }
        route = .note(name)
        loadNote(name)
    }
    
    private func toggle(_ task: NoteTask) {
        saveIfDirty()
        _ = try? toggleTask(task, in: store)
        loadNote(activeNoteName)
        refreshTick += 1
    }
    
    private func setSettings(_ open: Bool) {
        withAnimation(.easeOut(duration: 0.2)) { showingSettings = open }
    }
    
    private func createNote(_ typedName: String) -> Bool {
        guard let name = try? store.createNote(named: typedName) else { return false }
        reloadNoteNames()
        showingNewNote = false
        openNote(name)
        return true
    }
    
    private func openQuickOpen() {
        saveIfDirty()
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
            saveIfDirty()
            route = .folder
        } else {
            openNote(openTabs[max(0, index - 1)])
        }
    }
    
    private func syncFromDisk() {
        let disk = (try? store.read(activeNoteName)) ?? ""
        if noteText == loadedText, disk != loadedText {
            noteText = disk
            loadedText = disk
        }
        taskPanel.refresh()
        refreshTick += 1
    }
}

#Preview {
    ContentView()
        .frame(width: 1280, height: 820)
}
