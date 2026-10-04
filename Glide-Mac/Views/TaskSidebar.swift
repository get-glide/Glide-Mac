import SwiftUI
import GlideCore

enum SidebarRange: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
}

struct TaskSidebar: View {
    let groups: [TaskGroup]
    let currentNoteName: String
    @Binding var range: SidebarRange
    @Binding var source: TaskSource
    
    private var railTasks: [RailTask] {
        groups
            .first { $0.title == "scheduled" }?
            .tasks
            .compactMap { RailTask($0) } ?? []
    }
    
    private var untimedCount: Int {
        groups.first { $0.title == "anytime" }?.tasks.count ?? 0
    }
    
    private var isCurrentNote: Bool {
        if case .currentNote = source { return true }
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(range.rawValue)
                    .font(Theme.ui(14))
                    .foregroundStyle(Theme.label)
                
                Text(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.labelTertiary)
                
                Spacer()
            }
            .frame(height: Theme.barHeight)
            
            HStack(spacing: 6) {
                ForEach(SidebarRange.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .font(Theme.ui(11.5))
                        .foregroundStyle(range == option ? Theme.label : Theme.labelSecondary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(range == option ? Theme.surfaceTile : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .pressable {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                range = option
                            }
                        }
                }
            }
            .padding(.bottom, 10)
            
            HStack(spacing: 6) {
                Text("This Note")
                    .font(Theme.ui(11.5))
                    .foregroundStyle(isCurrentNote ? Theme.label : Theme.labelSecondary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(isCurrentNote ? Theme.surfaceTile : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .pressable {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            source = .currentNote(name: currentNoteName)
                        }
                    }
                
                Text("All Notes")
                    .font(Theme.ui(11.5))
                    .foregroundStyle(source == .allNotes ? Theme.label : Theme.labelSecondary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(source == .allNotes ? Theme.surfaceTile : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .pressable {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            source = .allNotes
                        }
                    }
            }
            .padding(.bottom, 10)
            
            if range == .today {
                TodayRail(tasks: railTasks)
                    .padding(.top, 4)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(groups.flatMap { $0.tasks }, id: \.lineIndex) { noteTask in
                        Text(noteTask.task.text)
                            .font(Theme.ui(12.5))
                            .foregroundStyle(Theme.label)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.top, 4)
            }
            
            GlideTile(padding: 12) {
                HStack {
                    Text("No time set")
                        .font(Theme.ui(12.5))
                        .foregroundStyle(Theme.label)
                    Spacer()
                    Text("\(untimedCount)")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.labelSecondary)
                }
            }
            .padding(.top, 12)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceSidebar)
    }
}
