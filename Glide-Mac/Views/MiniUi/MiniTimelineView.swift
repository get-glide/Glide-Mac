//
//  MiniTimelineView.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/4/26.
//



import SwiftUI
import GlideCore

// This week's tasks on a vertical rail: a week strip on top, then one section
// per day from today on, with a NOW line inside today.
//
// `tasks` should already be scoped to this week. Grouping by day and sorting
// happen here for display only and don't change any task data.
struct MiniTimelineView: View {
    let tasks: [NoteTask]
    let upNext: NoteTask?
    
    private let calendar = Calendar.current
    // Widths of the time and node columns. The rail line is offset by these, so
    // changing one without the other misaligns the line.
    private let timeColumn: CGFloat = 34
    private let nodeColumn: CGFloat = 16
    
    private var today: Date { calendar.startOfDay(for: .now) }
    
    // Seven days of the current week. Uses `Calendar.current`, so the first day
    // follows the user's locale, matching Core's `.thisWeek` scope.
    private var weekDays: [Date] {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: .now) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: week.start) }
    }
    
    // Tasks due on `day`. Timed tasks come first by time, then untimed tasks in
    // note order.
    private func tasks(on day: Date) -> [NoteTask] {
        tasks
            .filter { task in
                guard let due = task.task.dueDate else { return false }
                return calendar.isDate(due, inSameDayAs: day)
            }
            .sorted { a, b in
                switch (a.task.time, b.task.time) {
                case let (x?, y?): return x.minutesFromMidnight < y.minutesFromMidnight
                case (_?, nil): return true
                case (nil, _?): return false
                default: return a.lineIndex < b.lineIndex
                }
            }
    }
    
    // Days that get a section. Today always shows so the NOW line has a home.
    // Later days only show when they have tasks, and past days never do.
    private var railDays: [Date] {
        weekDays.filter { $0 >= today && ($0 == today || !tasks(on: $0).isEmpty) }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            weekStrip
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(railDays, id: \.self) { day in
                        daySection(day)
                    }
                }
                .padding(.bottom, 8)
                .background(alignment: .topLeading) {
                    Rectangle()
                        .fill(MiniStyle.accent.opacity(0.5))
                        .frame(width: 2)
                        .padding(.top, 8)
                        .offset(x: timeColumn + nodeColumn / 2 - 1)
                }
            }
        }
    }
    
    // Week strip
    
    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                let isToday = day == today
                let isPast = day < today
                let dayTasks = tasks(on: day)
                VStack(spacing: 4) {
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(Theme.mono(10))
                        .foregroundStyle(isToday ? MiniStyle.amber : MiniStyle.textMuted)
                    Text(day.formatted(.dateTime.day()))
                        .font(Theme.mono(12))
                        .foregroundStyle(isToday ? MiniStyle.page : (isPast ? Color.white.opacity(0.45) : Color.white))
                        .frame(width: 26, height: 26)
                        .background(isToday ? MiniStyle.amber : .clear, in: Circle())
                    HStack(spacing: 2) {
                        ForEach(0..<min(dayTasks.count, 3), id: \.self) { i in
                            Circle()
                                .fill(isPast || dayTasks[i].task.checked ? Color.white.opacity(0.3) : MiniStyle.accent)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(MiniStyle.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    // Rail
    
    @ViewBuilder
    private func daySection(_ day: Date) -> some View {
        let isToday = day == today
        let dayTasks = tasks(on: day)
        let openCount = dayTasks.filter { !$0.task.checked }.count
        
        railRow {
            Color.clear
        } node: {
            Circle()
                .fill(MiniStyle.page)
                .overlay(Circle().stroke(isToday ? MiniStyle.amber : Color.white.opacity(0.5), lineWidth: 2))
                .frame(width: 11, height: 11)
        } content: {
            HStack {
                Text(isToday ? "TODAY" : day.formatted(.dateTime.weekday(.wide)).uppercased())
                    .font(Theme.mono(11))
                    .tracking(0.9)
                    .foregroundStyle(isToday ? MiniStyle.amber : MiniStyle.textSoft)
                Spacer()
                if !dayTasks.isEmpty {
                    Text("\(openCount)")
                        .font(Theme.mono(11))
                        .foregroundStyle(MiniStyle.textMuted)
                }
            }
            .padding(.leading, 4)
        }
        .padding(.top, day == railDays.first ? 2 : 10)
        
        ForEach(Array(dayTasks.enumerated()), id: \.element.miniID) { offset, task in
            if isToday && isFirstAfterNow(task, at: offset, in: dayTasks) {
                nowRow
            }
            taskRow(task, isToday: isToday)
        }
        if isToday && nowGoesLast(dayTasks) {
            nowRow
        }
    }
    
    private var nowMinutes: Int {
        calendar.component(.hour, from: .now) * 60 + calendar.component(.minute, from: .now)
    }
    
    // True for the first timed task after the current time, so NOW is drawn above it.
    private func isFirstAfterNow(_ task: NoteTask, at offset: Int, in list: [NoteTask]) -> Bool {
        guard let time = task.task.time, time.minutesFromMidnight > nowMinutes else { return false }
        if offset == 0 { return true }
        guard let previous = list[offset - 1].task.time else { return false }
        return previous.minutesFromMidnight <= nowMinutes
    }
    
    // True when every timed task today has passed, so NOW belongs at the bottom.
    private func nowGoesLast(_ list: [NoteTask]) -> Bool {
        let timed = list.compactMap { $0.task.time }
        return !timed.contains { $0.minutesFromMidnight > nowMinutes }
    }
    
    private var nowRow: some View {
        railRow {
            Text(Date.now.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute()))
                .font(Theme.mono(10))
                .foregroundStyle(MiniStyle.now)
        } node: {
            Circle()
                .fill(MiniStyle.now)
                .frame(width: 9, height: 9)
                .shadow(color: MiniStyle.now.opacity(0.5), radius: 4)
        } content: {
            Rectangle().fill(MiniStyle.now).frame(height: 2)
        }
        .frame(height: 18)
        .accessibilityLabel("Now")
    }
    
    private func taskRow(_ task: NoteTask, isToday: Bool) -> some View {
        let done = task.task.checked
        let isNext = upNext.map { $0.noteName == task.noteName && $0.lineIndex == task.lineIndex } ?? false
        
        return railRow(alignment: .top) {
            Text(task.task.time?.miniLabel ?? "")
                .font(Theme.mono(10))
                .foregroundStyle(done ? Color.white.opacity(0.4) : (isToday ? MiniStyle.amber : MiniStyle.textSoft))
                .padding(.top, 12)
        } node: {
            Circle()
                .fill(done ? Color.white.opacity(0.4) : (isNext ? MiniStyle.amber : MiniStyle.page))
                .overlay(Circle().stroke(done ? Color.white.opacity(0.4) : (isNext ? MiniStyle.amber : MiniStyle.accent), lineWidth: 2))
                .frame(width: 9, height: 9)
                .padding(.top, 14)
        } content: {
            HStack(spacing: 10) {
                MiniCheckbox(checked: done, size: 18)
                VStack(alignment: .leading, spacing: 2) {
                    if isNext {
                        Text("UP NEXT")
                            .font(Theme.mono(9))
                            .tracking(0.7)
                            .foregroundStyle(MiniStyle.amber)
                    }
                    Text(task.task.text)
                        .font(Theme.ui(14))
                        .fontWeight(.semibold)
                        .foregroundStyle(done ? Color.white.opacity(0.5) : Color.white)
                        .strikethrough(done, color: Color.white.opacity(0.5))
                        .lineLimit(1)
                    Text(task.noteName)
                        .font(Theme.mono(10))
                        .foregroundStyle(done ? Color.white.opacity(0.4) : MiniStyle.accent)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .background(done ? Color.white.opacity(0.04) : MiniStyle.accent.opacity(0.16),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .leading) {
                UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, style: .continuous)
                    .fill(done ? Color.white.opacity(0.2) : MiniStyle.accent)
                    .frame(width: 3)
            }
            .overlay {
                if isNext {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(MiniStyle.amber.opacity(0.6), lineWidth: 1.5)
                        .padding(-2)
                }
            }
            .padding(.leading, 4)
        }
    }
    
    // Lays out one rail row in three fixed columns: time, node, content. Every row
    // uses this so the nodes stay centered on the rail line.
    private func railRow<Time: View, Node: View, Content: View>(
        alignment: VerticalAlignment = .center,
        @ViewBuilder time: () -> Time,
        @ViewBuilder node: () -> Node,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: alignment, spacing: 0) {
            time()
                .frame(width: timeColumn, alignment: .trailing)
            node()
                .frame(width: nodeColumn)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

