//
//  TasksPage.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/10/26.
//

import SwiftUI
import GlideCore

struct TasksPage: View {
    let tasks: [NoteTask]
    let onOpen: (String) -> Void
    var onToggle: ((NoteTask) -> Void)? = nil
    
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
                if task.task.hasCheckbox {
                    Image(systemName: task.task.checked ? "checkmark.square.fill" : "square")
                        .foregroundStyle(task.task.checked ? Theme.labelTertiary : Theme.labelSecondary)
                        .contentShape(Rectangle())
                        .pressable { onToggle?(task) }
                        .accessibilityLabel(task.task.checked ? "Mark not done" : "Mark done")
                        .accessibilityAddTraits(.isButton)
                }
                
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
}
