//
//  MiniView.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/4/26.
//


import SwiftUI
import AppKit
import GlideCore

// The three views the mini window can show. Raw values are stored in
// `@AppStorage`, so renaming a case resets the user's last-used view.
enum MiniTab: String, CaseIterable {
    case notes, timeline
}

// Root of the menu bar mini window.
//
// Reads notes from the existing `NoteStore` and tasks from `TaskPanelViewModel`.
// It does not save anything. Typed text in the notes view stays in memory and is
// replaced by the file's contents the next time the view reloads.
struct MiniView: View {
    private let store: NoteStore
    @StateObject private var panel: TaskPanelViewModel

    @AppStorage("miniTab") private var tab: MiniTab = .timeline
    @AppStorage("miniRange") private var range: SidebarRange = .week
    @State private var noteName = DefaultNote.today.rawValue
    @State private var noteText = ""
    @State private var loadedText = ""
    @State private var noteNames: [String] = []
    @State private var searchOpen = false
    @State private var query = ""
    @State private var selectedDay = Calendar.current.startOfDay(for: .now)
    @State private var saveTask: Task<Void, Never>?

    @Environment(\.openWindow) private var openWindow
    
    private var allTasks: [NoteTask] { panel.groups.flatMap(\.tasks) }
    private var tasksByDay: [Date: [NoteTask]] { allTasks.groupedByDay() }
    private var upNext: NoteTask? {
        Calendar.current.isDateInToday(selectedDay) ? panel.currentTask : nil
    }
    
    init() {
        let store = try! NoteStore.makeDefault()
        self.store = store
        _panel = StateObject(wrappedValue: TaskPanelViewModel(store: store, scope: .anyDate, source: .allNotes))
        FontLoader.registerFonts()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            
            Group {
                switch tab {
                case .notes:
                    MiniNoteView(title: noteName, text: $noteText)
                case .timeline:
                    VStack(spacing: 10) {
                        CalendarCard(tasksByDay: tasksByDay, range: $range, selectedDay: $selectedDay)
                        TimelineRail(
                            days: [selectedDay],
                            tasksByDay: tasksByDay,
                            overdue: overdueTasks(allTasks),
                            upNext: upNext,
                            showSomeday: false,
                            onOpen: open,
                            onToggle: toggle
                        )
                        AddTaskField(target: "Today", onAdd: addTask)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(14)
        .frame(width: MiniStyle.width, height: MiniStyle.height, alignment: .topLeading)
        .background(MiniStyle.background)
        .overlay {
            if searchOpen { searchOverlay }
        }
        .preferredColorScheme(.dark)
        .environment(\.timelineStyle, .mini)
        .onAppear {
            selectedDay = Calendar.current.startOfDay(for: .now)
            loadNote()
            panel.refresh()
        }
        .onChange(of: noteText) { _, _ in scheduleAutosave() }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)) { _ in saveIfDirty() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in saveIfDirty() }
        .onDisappear { saveIfDirty() }
    }
    
    private func loadNote() {
        let text = (try? store.read(noteName)) ?? ""
        noteText = text
        loadedText = text
    }

    private func saveIfDirty() {
        guard noteText != loadedText else { return }
        do {
            try store.write(noteText, to: noteName)
            loadedText = noteText
        } catch {
            print("save failed: \(error)")
        }
    }

    private func toggle(_ task: NoteTask) {
        saveIfDirty()
        _ = try? toggleTask(task, in: store)
        loadNote()
        panel.refresh()
    }

    private func addTask(_ text: String) {
        let line = TaskEntry.line(from: text, defaultDue: selectedDay)
        saveIfDirty()
        let note = DefaultNote.today.rawValue
        let existing = (try? store.read(note)) ?? ""
        try? store.write(existing.appendingLine(line), to: note)
        loadNote()
        panel.refresh()
    }

    private func open(_ name: String) {
        saveIfDirty()
        noteName = name
        loadNote()
        tab = .notes
        searchOpen = false
    }
    
    // Header
    private var header: some View {
        HStack(spacing: 10) {
            MiniGlass(radius: 16) {
                HStack(spacing: 2) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Text("GLIDE")
                        .font(Theme.display(14))
                        .foregroundStyle(Color.white)
                        .padding(.leading, 5)
                        .padding(.trailing, 6)
                    tabButton(.notes, icon: "book", key: "1", help: "Notes")
                    tabButton(.timeline, icon: "checkmark.square", key: "2", help: "Timeline")
                }
                .padding(.leading, 10)
                .padding(.trailing, 3)
                .frame(height: 32)
            }
            
            Text(title)
                .font(Theme.ui(17))
                .foregroundStyle(MiniStyle.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            headerButton(icon: "magnifyingglass", help: "Find a note") {
                query = ""
                noteNames = (try? store.listNotes()) ?? []
                searchOpen = true
            }
            .keyboardShortcut("p", modifiers: .command)
            
            headerButton(icon: "arrow.up.right.square", help: "Open Glide") {
                openMainWindow()
            }
            .keyboardShortcut("o", modifiers: .command)
        }
    }
    
    private var title: String {
        switch tab {
        case .notes: return noteName
        case .timeline: return Date.now.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
        }
    }
    
    private func tabButton(_ value: MiniTab, icon: String, key: Character, help: String) -> some View {
        let isOn = tab == value
        return Button {
            tab = value
            reload()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isOn ? Color.white : MiniStyle.textSoft)
                .frame(width: 30, height: 24)
                .background(isOn ? Color.white.opacity(0.18) : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
        .keyboardShortcut(KeyEquivalent(key), modifiers: .command)
        .help(help)
        .accessibilityLabel(help)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
    
    private func headerButton(icon: String, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            MiniGlass {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MiniStyle.textSoft)
                    .frame(width: 30, height: 30)
            }
        }
        .buttonStyle(.plain)
        .help(help)
        .accessibilityLabel(help)
    }
    
    // Search
    
    // Note names matching the query, alphabetical. Matches on file name only,
    // not note contents.
    private var filteredNames: [String] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        let sorted = noteNames.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        guard !q.isEmpty else { return sorted }
        return sorted.filter { $0.lowercased().contains(q) }
    }
    
    private var searchOverlay: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.6)
                .onTapGesture { searchOpen = false }
            
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(MiniStyle.textMuted)
                    TextField("", text: $query)
                        .textFieldStyle(.plain)
                        .font(Theme.ui(15))
                        .foregroundStyle(MiniStyle.text)
                        .onSubmit {
                            if let first = filteredNames.first { open(first) }
                        }
                        .onExitCommand { searchOpen = false }
                        .accessibilityLabel("Find a note")
                }
                .padding(.horizontal, 14)
                .frame(height: 46)
                
                Rectangle().fill(MiniStyle.panelLine).frame(height: 1)
                
                ScrollView {
                    VStack(spacing: 1) {
                        ForEach(filteredNames, id: \.self) { name in
                            Button { open(name) } label: {
                                HStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(MiniStyle.accent)
                                        .frame(width: 7, height: 7)
                                    Text(name)
                                        .font(Theme.ui(13))
                                        .foregroundStyle(MiniStyle.text)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .frame(height: 36)
                                .background(name == noteName ? MiniStyle.selected : .clear,
                                            in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(6)
                }
                .frame(maxHeight: 340)
            }
            .background(MiniStyle.panel, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(MiniStyle.panelLine, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 25, y: 20)
            .padding(.horizontal, 12)
            .padding(.top, 56)
        }
    }
    
    private func scheduleAutosave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            if !Task.isCancelled { saveIfDirty() }
        }
    }
    
    private func syncFromDisk() {
        let disk = (try? store.read(noteName)) ?? ""
        if noteText == loadedText, disk != loadedText {
            noteText = disk
            loadedText = disk
        }
        panel.refresh()
    }
    
    // Data
    
    // Re-reads the current note and refreshes both task panels.
    //
    // `TaskPanelViewModel` has no public refresh method, but setting `source` or
    // `scope` runs its existing `didSet { refresh() }`. Called on appear and on
    // every tab switch so the mini picks up edits made in the main window.
    private func reload() {
        noteText = (try? store.read(noteName)) ?? ""
    }
    
    // Brings the main window forward, or opens a new one if it was closed.
    //
    // Calling `openWindow(id:)` alone would create a second window when one is
    // already open, so it checks for an existing window first. SwiftUI prefixes
    // window identifiers with the scene id.
    private func openMainWindow() {
        NSApp.activate()
        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue.hasPrefix("main") == true }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            openWindow(id: "main")
        }
    }
}
