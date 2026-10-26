//
//  TaskPanelViewModel.swift
//  Glide-Mac
//
//  Created by Pranay Venkat Aluri on 9/27/26.
//

import Foundation
import Combine
import GlideCore

class TaskPanelViewModel: ObservableObject {
    @Published var groups: [TaskGroup] = []
    @Published var currentTask: NoteTask? = nil
    @Published var noDueDateTasks: [NoteTask] = []
    
    var scope: TaskScope { didSet { refresh() } }
    var source: TaskSource { didSet { refresh() } }
    
    private var currentLines: [String] = []
    private var currentNoteName: String = DefaultNote.today.rawValue
    private let store: NoteStore
    
    init(
        store: NoteStore,
        scope: TaskScope = .today,
        source: TaskSource = .currentNote(name: DefaultNote.today.rawValue),
        noteName: String = DefaultNote.today.rawValue
    ) {
        self.store = store
        self.scope = scope
        self.source = source
        self.currentNoteName = noteName
        refresh()
    }
    
    func update(lines: [String], noteName: String) {
        currentLines = lines
        currentNoteName = noteName
        refresh()
    }
    
    func refresh() {
        let effectiveSource: TaskSource
        switch source {
            case .currentNote: effectiveSource = .currentNote(name: currentNoteName)
            case .allNotes: effectiveSource = .allNotes
        }
        do {
            let result = try getTaskPanel(
                currentLines: currentLines,
                currentNoteName: currentNoteName,
                scope: scope,
                source: effectiveSource,
                store: store
            )
            groups = result.groups
            currentTask = result.current
            noDueDateTasks = result.all.filter { $0.task.dueDate == nil }
        } catch {
            print("TaskPanelViewModel error: \(error)")
        }
    }
}
