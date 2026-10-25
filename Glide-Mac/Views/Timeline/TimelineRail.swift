//
//  TimelineRail.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
//

import SwiftUI
import GlideCore

struct TimelineRail: View {
    let tasksByDay: [Date: [NoteTask]]
    let noDueDateTasks: [NoteTask]
    let upNext: NoteTask?
    let onOpen: (String) -> Void
    
    @State private var noDueDateExpanded = false
    @AppStorage("use24HourTime") private var use24Hour = false
    
    private var today: Date { Calendar.current.startOfDay(for: .now) }
    
    var body: some View {
        let days = Calendar.current.days(of: .weekOfYear)
            .filter { $0 == today || ($0 > today && tasksByDay[$0] != nil) }
        
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(days, id: \.self) { day in
                    daySection(day, isFirst: day == days.first)
                }
                someday
            }
            .padding(.bottom, 20)
            .background(alignment: .topLeading) {
                Rectangle()
                    .fill(Theme.accent.opacity(0.6))
                    .frame(width: 2)
                    .padding(.top, 10)
                    .offset(x: RailMetrics.time + RailMetrics.node / 2 - 1)
            }
        }
        .scrollIndicators(.never)
    }
    
    @ViewBuilder
    private func daySection(_ day: Date, isFirst: Bool) -> some View {
        let isToday = day == today
        let tasks = tasksByDay[day] ?? []
        let clock = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let nowMinutes = (clock.hour ?? 0) * 60 + (clock.minute ?? 0)
        let nowIndex = tasks.firstIndex { ($0.task.time?.railMinutes ?? -1) > nowMinutes } ?? tasks.count
        let openCount = tasks.filter { !$0.task.checked }.count
        
        RailRow {
            Color.clear
        } node: {
            Circle()
                .fill(Theme.chrome)
                .overlay(Circle().stroke(isToday ? Theme.amber : Color.white.opacity(0.5), lineWidth: 2))
                .frame(width: 13, height: 13)
        } content: {
            HStack {
                Text(isToday ? "TODAY" : day.formatted(.dateTime.weekday(.wide)).uppercased())
                    .font(Theme.mono(11))
                    .fontWeight(.semibold)
                    .tracking(0.9)
                    .foregroundStyle(isToday ? Theme.amber : Theme.chromeText)
                Spacer()
                if !tasks.isEmpty {
                    Text(isToday ? (openCount == 0 ? "all done" : "\(openCount) left") : "\(tasks.count)")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.chromeText)
                }
            }
            .padding(.leading, 4)
        }
        .padding(.top, isFirst ? 2 : 14)
        
        ForEach(Array(tasks.enumerated()), id: \.element.railID) { index, task in
            if isToday && index == nowIndex {
                nowRow
            }
            taskRow(task, isToday: isToday)
        }
        if isToday && nowIndex == tasks.count {
            nowRow
        }
    }
    
    private var nowRow: some View {
        RailRow {
            Text(Date.now.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute()))
                .font(Theme.mono(10))
                .fontWeight(.semibold)
                .foregroundStyle(Theme.now)
        } node: {
            Circle()
                .fill(Theme.now)
                .frame(width: 9, height: 9)
                .background(Circle().fill(Theme.now.opacity(0.25)).frame(width: 17, height: 17))
        } content: {
            Rectangle().fill(Theme.now).frame(height: 2)
        }
        .frame(height: 22)
        .accessibilityLabel("Now")
    }
    
    private func taskRow(_ task: NoteTask, isToday: Bool) -> some View {
        let done = task.task.checked
        let isNext = task.railID == upNext?.railID
        
        return RailRow(alignment: .top) {
            Text(task.task.time?.railLabel(use24Hour: use24Hour) ?? "")
                .font(Theme.mono(10))
                .fontWeight(.medium)
                .foregroundStyle(done ? Color.white.opacity(0.4) : (isToday ? Theme.amber : Theme.chromeText))
                .padding(.top, 12)
        } node: {
            Circle()
                .fill(done ? Color.white.opacity(0.4) : (isNext ? Theme.amber : Theme.chrome))
                .overlay(Circle().stroke(done ? Color.white.opacity(0.4) : (isNext ? Theme.amber : Theme.accent), lineWidth: 2))
                .frame(width: 9, height: 9)
                .padding(.top, 13)
        } content: {
            TaskCard(task: task, isNext: isNext, onOpen: onOpen)
                .padding(.leading, 4)
        }
    }
    
    @ViewBuilder
    private var someday: some View {
        RailRow {
            Color.clear
        } node: {
            Circle()
                .strokeBorder(Theme.accent.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [2, 2]))
                .background(Circle().fill(Theme.chrome))
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
                .foregroundStyle(Theme.chromeText)
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
                    Button { onOpen(task.noteName) } label: {
                        HStack(spacing: 8) {
                            Image(systemName: task.task.checked ? "checkmark.square.fill" : "square")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.chromeText)
                            Text(task.task.text)
                                .font(Theme.ui(13))
                                .foregroundStyle(task.task.checked ? Color.white.opacity(0.5) : Theme.label)
                                .strikethrough(task.task.checked, color: Color.white.opacity(0.5))
                                .lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .padding(.leading, 4)
                        .frame(height: 26)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity)
            }
        }
    }
}

