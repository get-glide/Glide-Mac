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
    
    var scope: TaskScope = .today { didSet { refresh() } }
    var source: TaskSource = .currentNote(name: DefaultNote.today.rawValue) { didSet { refresh() } }
    
    private var currentLines: [String] = []
    private var currentNoteName: String = DefaultNote.today.rawValue
    private let store: NoteStore
    
    init(store: NoteStore) {
        self.store = store
        refresh()
    }
    
    func update(lines: [String], noteName: String) {
        currentLines = lines
        currentNoteName = noteName
        source = .currentNote(name: noteName)
        refresh()
    }
    
    private func refresh() {
        do {
            let result = try getTaskPanel(
                currentLines: currentLines,
                currentNoteName: currentNoteName,
                scope: scope,
                source: source,
                store: store
            )
            groups = result.groups
            currentTask = result.current
        } catch {
            print("TaskPanelViewModel error: \(error)")
        }
    }
}
