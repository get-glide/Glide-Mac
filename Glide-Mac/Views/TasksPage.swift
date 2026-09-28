//
//  TasksPage.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/10/26.
//

import SwiftUI
import GlideCore

struct TasksPage: View {
    @State private var tasks: [NoteTask]
    let onOpen: (String) -> Void
    
    init(tasks: [NoteTask], onOpen: @escaping (String) -> Void) {
        _tasks = State(initialValue: tasks)
        self.onOpen = onOpen
    }
    
    private var grouped: [(subject: String, tasks: [NoteTask])] {
        let dict = Dictionary(grouping: tasks, by: { $0.noteName })
        return dict.keys.sorted().map { key in (subject: key, tasks: dict[key] ?? []) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(grouped, id: \.subject) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(group.subject)
                            .font(Theme.ui(13))
                            .foregroundStyle(Theme.labelSecondary)
                        
                        ForEach(group.tasks, id: \.lineIndex) { task in
                            row(for: task)
                        }
                    }
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceApp)
    }
    
    private func row(for task: NoteTask) -> some View {
        GlideTile {
            HStack {
                Image(systemName: task.task.checked ? "checkmark.square.fill" : "square")
                    .foregroundStyle(task.task.checked ? Theme.labelTertiary : Theme.labelSecondary)
                    .contentShape(Rectangle())
                    .pressable { toggle(task) }
                
                Text(task.task.text)
                    .font(Theme.ui(13.5))
                    .foregroundStyle(task.task.checked ? Theme.labelTertiary : Theme.label)
                    .strikethrough(task.task.checked)
                    .contentShape(Rectangle())
                    .pressable { onOpen(task.noteName) }
                
                Spacer()
                
                if let time = task.task.time {
                    Text(String(format: "%02d:%02d", time.hour, time.minute))
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.labelTertiary)
                }
            }
        }
    }
    
    private func toggle(_ task: NoteTask) {
        // TODO: implement checkbox toggle via NoteStore
    }
}
