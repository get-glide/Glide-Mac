//
//  TimelineRail.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
//

import SwiftUI
import GlideCore

struct TimelineRail: View {
    let days: [Date]
    let tasksByDay: [Date: [NoteTask]]
    var overdue: [NoteTask] = []
    var noDueDateTasks: [NoteTask] = []
    var upNext: NoteTask? = nil
    var showSomeday = true
    let onOpen: (String) -> Void
    var onToggle: ((NoteTask) -> Void)? = nil
    
    @State private var noDueDateExpanded = false
    @AppStorage("use24HourTime") private var use24Hour = false
    @Environment(\.timelineStyle) private var style

    private var today: Date { Calendar.current.startOfDay(for: .now) }
    private var showOverdue: Bool { !overdue.isEmpty && days.contains(today) }

    static func upcomingDays(_ tasksByDay: [Date: [NoteTask]]) -> [Date] {
        let today = Calendar.current.startOfDay(for: .now)
        return Calendar.current.days(of: .weekOfYear)
            .filter { $0 == today || ($0 > today && tasksByDay[$0] != nil) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if showOverdue { overdueSection }
                ForEach(days, id: \.self) { day in
                    daySection(day, isFirst: day == days.first && !showOverdue)
                }
                if showSomeday { someday }
            }
            .padding(.bottom, 20)
            .background(alignment: .topLeading) {
                Rectangle()
                    .fill(style.line)
                    .frame(width: 2)
                    .padding(.top, 10)
                    .offset(x: RailMetrics.time + RailMetrics.node / 2 - 1)
            }
        }
        .scrollIndicators(.never)
    }
    
    @ViewBuilder
    private var overdueSection: some View {
        RailRow {
            Color.clear
        } node: {
            Circle()
                .fill(style.background)
                .overlay(Circle().stroke(style.secondaryText, lineWidth: 2))
                .frame(width: 13, height: 13)
        } content: {
            Text("OVERDUE · \(overdue.count)")
                .font(Theme.mono(11))
                .fontWeight(.semibold)
                .tracking(0.9)
                .foregroundStyle(style.secondaryText)
                .padding(.leading, 4)
        }
        .padding(.top, 2)

        ForEach(overdue, id: \.railID) { task in
            taskRow(task, isToday: false,
                    timeLabel: task.task.dueDate?.formatted(.dateTime.month(.defaultDigits).day()))
        }
    }

    private func nowRowIndex(in tasks: [NoteTask], nowMinutes: Int) -> Int {
        if let next = tasks.firstIndex(where: { ($0.task.time?.railMinutes ?? -1) > nowMinutes }) {
            return next
        }
        return (tasks.lastIndex { $0.task.time != nil } ?? -1) + 1
    }

    @ViewBuilder
    private func daySection(_ day: Date, isFirst: Bool) -> some View {
        let isToday = day == today
        let tasks = tasksByDay[day] ?? []
        let clock = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let nowMinutes = (clock.hour ?? 0) * 60 + (clock.minute ?? 0)
        let nowIndex = nowRowIndex(in: tasks, nowMinutes: nowMinutes)
        let checkable = tasks.filter { $0.task.hasCheckbox }
        let openCount = checkable.filter { !$0.task.checked }.count
        let countLabel = (isToday && !checkable.isEmpty)
            ? (openCount == 0 ? "all done" : "\(openCount) left")
            : "\(tasks.count)"

        RailRow {
            Color.clear
        } node: {
            Circle()
                .fill(style.background)
                .overlay(Circle().stroke(isToday ? style.amber : Color.white.opacity(0.5), lineWidth: 2))
                .frame(width: 13, height: 13)
        } content: {
            HStack {
                Text(isToday ? "TODAY" : day.formatted(.dateTime.weekday(.wide)).uppercased())
                    .font(Theme.mono(11))
                    .fontWeight(.semibold)
                    .tracking(0.9)
                    .foregroundStyle(isToday ? style.amber : style.secondaryText)
                Spacer()
                if !tasks.isEmpty {
                    Text(countLabel)
                        .font(Theme.mono(11))
                        .foregroundStyle(style.secondaryText)
                }
            }
            .padding(.leading, 4)
        }
        .padding(.top, isFirst ? 2 : 14)

        ForEach(Array(tasks.enumerated()), id: \.element.railID) { index, task in
            if isToday && index == nowIndex { nowRow }
            taskRow(task, isToday: isToday)
        }
        if isToday && nowIndex >= tasks.count { nowRow }
    }

    private var nowRow: some View {
        RailRow {
            Text(Date.now.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute()))
                .font(Theme.mono(10))
                .fontWeight(.semibold)
                .foregroundStyle(style.now)
        } node: {
            Circle()
                .fill(style.now)
                .frame(width: 9, height: 9)
                .background(Circle().fill(style.now.opacity(0.25)).frame(width: 17, height: 17))
        } content: {
            Rectangle().fill(style.now).frame(height: 2)
        }
        .frame(height: 22)
        .accessibilityLabel("Now")
    }

    private func taskRow(_ task: NoteTask, isToday: Bool, timeLabel: String? = nil) -> some View {
        let done = task.task.checked
        let isNext = task.railID == upNext?.railID

        return RailRow(alignment: .top) {
            Text(timeLabel ?? task.task.time?.railLabel(use24Hour: use24Hour) ?? "")
                .font(Theme.mono(10))
                .fontWeight(.medium)
                .foregroundStyle(done ? Color.white.opacity(0.4) : (isToday ? style.amber : style.secondaryText))
                .padding(.top, 12)
        } node: {
            Circle()
                .fill(done ? Color.white.opacity(0.4) : (isNext ? style.amber : style.background))
                .overlay(Circle().stroke(done ? Color.white.opacity(0.4) : (isNext ? style.amber : style.accent), lineWidth: 2))
                .frame(width: 9, height: 9)
                .padding(.top, 13)
        } content: {
            TaskCard(task: task, isNext: isNext, onOpen: onOpen, onToggle: onToggle)
                .padding(.leading, 4)
        }
    }
    
    @ViewBuilder
    private var someday: some View {
        RailRow {
            Color.clear
        } node: {
            Circle()
                .strokeBorder(style.accent.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [2, 2]))
                .background(Circle().fill(style.background))
                .frame(width: 13, height: 13)
        } content: {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) { noDueDateExpanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Text("SOMEDAY · \(noDueDateTasks.count)")
                        .font(Theme.mono(11))
                        .fontWeight(.semibold)
                        .tracking(0.9)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .rotationEffect(.degrees(noDueDateExpanded ? 180 : 0))
                }
                .foregroundStyle(style.secondaryText)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.leading, 4)
        }
        .padding(.top, 12)

        if noDueDateExpanded {
            ForEach(noDueDateTasks, id: \.railID) { task in
                RailRow {
                    Color.clear
                } node: {
                    Color.clear
                } content: {
                    HStack(spacing: 8) {
                        if task.task.hasCheckbox {
                            Button { onToggle?(task) } label: {
                                Image(systemName: task.task.checked ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 12))
                                    .foregroundStyle(style.secondaryText)
                            }
                            .buttonStyle(.plain)
                        }
                        Button { onOpen(task.noteName) } label: {
                            Text(task.task.text)
                                .font(Theme.ui(13))
                                .foregroundStyle(task.task.checked ? Color.white.opacity(0.5) : style.primaryText)
                                .strikethrough(task.task.checked, color: Color.white.opacity(0.5))
                                .lineLimit(1)
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: 0)
                    }
                    .padding(.leading, 4)
                    .frame(height: 26)
                }
                .transition(.opacity)
            }
        }
    }
}

