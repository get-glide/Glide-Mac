//
//  TasksPage.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/10/26.
//

import SwiftUI
import GlideCore

import SwiftUI

struct TasksPage: View {
    @State private var tasks: [AggregatedTask]
    let onOpen: (String) -> Void
    
    init(tasks: [AggregatedTask], onOpen: @escaping (String) -> Void) {
        _tasks = State(initialValue: tasks)
        self.onOpen = onOpen
    }
    
    private var grouped: [(subject: String, tasks: [AggregatedTask])] {
        let dict = Dictionary(grouping: tasks, by: { $0.sourceNote })
        return dict.keys.sorted().map { key in (subject: key, tasks: dict[key] ?? []) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Tasks")
                    .font(Theme.ui(14))
                    .foregroundStyle(Theme.label)
                Spacer()
            }
            .frame(height: Theme.barHeight)
            .padding(.horizontal, 16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(grouped, id: \.subject) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(group.subject)
                                .font(Theme.ui(13))
                                .foregroundStyle(Theme.labelSecondary)
                            
                            ForEach(group.tasks) { task in
                                row(for: task)
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceApp)
    }
    
    private func row(for task: AggregatedTask) -> some View {
        GlideTile {
            HStack {
                Image(systemName: task.checked ? "checkmark.square.fill" : "square")
                    .foregroundStyle(task.checked ? Theme.labelTertiary : Theme.labelSecondary)
                    .contentShape(Rectangle())
                    .pressable { toggle(task) }
                
                Text(task.text)
                    .font(Theme.ui(13.5))
                    .foregroundStyle(task.checked ? Theme.labelTertiary : Theme.label)
                    .strikethrough(task.checked)
                    .contentShape(Rectangle())
                    .pressable { onOpen(task.sourceNote) }
                
                Spacer()
                
                if let time = task.time {
                    Text(String(format: "%02d:%02d", time.hour, time.minute))
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.labelTertiary)
                }
            }
        }
    }
    
    private func toggle(_ task: AggregatedTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].checked.toggle()
    }
}
