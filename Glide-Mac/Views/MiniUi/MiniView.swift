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
    case notes, timeline, month
}

// Root of the menu bar mini window.
//
// Reads notes from the existing `NoteStore` and tasks from `TaskPanelViewModel`.
// It does not save anything. Typed text in the notes view stays in memory and is
// replaced by the file's contents the next time the view reloads.
struct MiniView: View {
    private let store: NoteStore
    @StateObject private var weekPanel: TaskPanelViewModel
    @StateObject private var monthPanel: TaskPanelViewModel
    
    @AppStorage("miniTab") private var tab: MiniTab = .timeline
    @State private var noteName: String = DefaultNote.today.rawValue
    @State private var noteText: String = ""
    @State private var noteNames: [String] = []
    @State private var searchOpen = false
    @State private var query = ""
    @State private var selectedDay = Calendar.current.startOfDay(for: .now)
    
    @Environment(\.openWindow) private var openWindow
    
    init() {
        let store = try! NoteStore.makeDefault()
        self.store = store
        _weekPanel = StateObject(wrappedValue: TaskPanelViewModel(store: store))
        _monthPanel = StateObject(wrappedValue: TaskPanelViewModel(store: store))
        // The menu bar window can be created before ContentView, so it registers
        // fonts too. A second registration only logs a harmless failure.
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
                    MiniTimelineView(
                        tasks: weekTasks,
                        upNext: upNext
                    )
                case .month:
                    MiniMonthView(
                        tasks: monthPanel.groups.flatMap { $0.tasks },
                        selectedDay: $selectedDay
                    )
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
        .onAppear(perform: reload)
    }
    
    // Week data
    
    private var weekTasks: [NoteTask] {
        weekPanel.groups.flatMap { $0.tasks }
    }
    
    // The task to highlight as UP NEXT.
    //
    // Core's `currentTask(from:)` compares time of day only, not dates. Passing it
    // the whole week could pick a Thursday 7pm task on Monday, so it gets today's
    // tasks only.
    private var upNext: NoteTask? {
        let todays = weekTasks.filter { task in
            guard let due = task.task.dueDate else { return false }
            return Calendar.current.isDateInToday(due)
        }
        return currentTask(from: todays)
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
                    tabButton(.month, icon: "calendar", key: "3", help: "Month")
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
        case .month: return Date.now.formatted(.dateTime.month(.wide))
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
    
    private func open(_ name: String) {
        noteName = name
        noteText = (try? store.read(name)) ?? ""
        tab = .notes
        searchOpen = false
    }
    
    // Data
    
    // Re-reads the current note and refreshes both task panels.
    //
    // `TaskPanelViewModel` has no public refresh method, but setting `source` or
    // `scope` runs its existing `didSet { refresh() }`. Called on appear and on
    // every tab switch so the mini picks up edits made in the main window.
    private func reload() {
        noteText = (try? store.read(noteName)) ?? ""
        
        weekPanel.source = .allNotes
        weekPanel.scope = .thisWeek
        monthPanel.source = .allNotes
        monthPanel.scope = .thisMonth
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
