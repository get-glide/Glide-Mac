import SwiftUI
import GlideCore

enum SidebarRange: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    
    var scope: TaskScope {
        switch self {
        case .today: .today
        case .week: .thisWeek
        case .month: .thisMonth
        }
    }
}

struct TaskSidebar: View {
    let groups: [TaskGroup]
    let noDueDateTasks: [NoteTask]
    let currentNoteName: String
    let upNext: NoteTask?
    @Binding var range: SidebarRange
    @Binding var source: TaskSource
    let onOpen: (String) -> Void
    
    @State private var selectedDay = Calendar.current.startOfDay(for: .now)
    
    private var monthOpen: Bool { range == .month }
    
    var body: some View {
        let tasksByDay = groups.flatMap(\.tasks).groupedByDay()
        
        VStack(alignment: .leading, spacing: 0) {
            header(tasksByDay)
            
            Group {
                if monthOpen {
                    TimelineDayList(day: selectedDay, tasks: tasksByDay[selectedDay] ?? [], onOpen: onOpen)
                } else {
                    TimelineRail(tasksByDay: tasksByDay, noDueDateTasks: noDueDateTasks, upNext: upNext, onOpen: onOpen)
                }
            }
            .transition(.opacity)
        }
        .padding(.leading, 14)
        .padding(.trailing, 6)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func header(_ tasksByDay: [Date: [NoteTask]]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("TIMELINE")
                    .font(Theme.mono(11))
                    .fontWeight(.semibold)
                    .tracking(0.9)
                    .foregroundStyle(Theme.accent)
                Spacer()
                HStack(spacing: 2) {
                    sourceButton("This note", for: .currentNote(name: currentNoteName))
                    sourceButton("All notes", for: .allNotes)
                }
                .padding(2)
                .background(Theme.card, in: Capsule())
            }
            
            Text(monthOpen
                 ? Date.now.formatted(.dateTime.month(.wide))
                 : Date.now.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
            .font(Theme.display(30))
            .tracking(-0.9)
            .foregroundStyle(Theme.label)
            .contentTransition(.opacity)
            
            CalendarCard(tasksByDay: tasksByDay, range: $range, selectedDay: $selectedDay)
                .padding(.top, 8)
        }
        .padding(.vertical, 8)
        .padding(.bottom, 6)
    }
    
    private func sourceButton(_ label: String, for value: TaskSource) -> some View {
        let isOn: Bool = switch (source, value) {
        case (.currentNote, .currentNote), (.allNotes, .allNotes): true
        default: false
        }
        
        return Button {
            withAnimation(.easeInOut(duration: 0.18)) { source = value }
        } label: {
            Text(label)
                .font(Theme.ui(11))
                .fontWeight(isOn ? .semibold : .regular)
                .foregroundStyle(isOn ? Color.white : Theme.chromeText)
                .padding(.horizontal, 8)
                .frame(height: 20)
                .background(isOn ? Color.white.opacity(0.16) : .clear, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
