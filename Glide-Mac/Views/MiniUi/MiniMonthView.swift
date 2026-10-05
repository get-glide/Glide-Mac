//
//  MiniMonthView.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/4/26.
//

import SwiftUI
import GlideCore

// This month as a calendar grid with up to three dots per day, and the
// selected day's tasks listed below.

// `tasks` should already be scoped to this month. `selectedDay` is a binding so
// the selection survives switching tabs in `MiniView`.
struct MiniMonthView: View {
    let tasks: [NoteTask]
    @Binding var selectedDay: Date
    
    private let calendar = Calendar.current
    private var today: Date { calendar.startOfDay(for: .now) }
    
    private var monthDays: [Date] {
        guard let month = calendar.dateInterval(of: .month, for: .now),
              let count = calendar.range(of: .day, in: .month, for: .now)?.count else { return [] }
        return (0..<count).compactMap { calendar.date(byAdding: .day, value: $0, to: month.start) }
    }
    
    // Empty cells before day 1 so it lands under the right weekday. Uses the
    // locale's first weekday instead of assuming Sunday or Monday.
    private var leadingBlanks: Int {
        guard let first = monthDays.first else { return 0 }
        let weekday = calendar.component(.weekday, from: first)
        return (weekday - calendar.firstWeekday + 7) % 7
    }
    
    // Weekday initials rotated to start on the locale's first weekday.
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
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
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            grid
            
            dayList
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }
    
    // Grid
    
    private var grid: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(Theme.mono(10))
                        .foregroundStyle(MiniStyle.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(0..<leadingBlanks, id: \.self) { _ in
                    Color.clear.frame(height: 40)
                }
                ForEach(monthDays, id: \.self) { day in
                    dayCell(day)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(MiniStyle.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private func dayCell(_ day: Date) -> some View {
        let isToday = day == today
        let isSelected = calendar.isDate(day, inSameDayAs: selectedDay)
        let isPast = day < today
        let dayTasks = tasks(on: day)
        
        return Button {
            selectedDay = day
        } label: {
            VStack(spacing: 3) {
                Text(day.formatted(.dateTime.day()))
                    .font(Theme.mono(12))
                    .foregroundStyle(isToday ? MiniStyle.page : (isPast ? Color.white.opacity(0.4) : Color.white))
                    .frame(width: 28, height: 28)
                    .background(isToday ? MiniStyle.amber : .clear, in: Circle())
                    .overlay {
                        if isSelected && !isToday {
                            Circle().stroke(MiniStyle.accent, lineWidth: 1.5)
                        }
                    }
                // Capped at three dots. The list below shows the full count.
                HStack(spacing: 2) {
                    ForEach(0..<min(dayTasks.count, 3), id: \.self) { i in
                        Circle()
                            .fill(isPast || dayTasks[i].task.checked ? Color.white.opacity(0.3) : MiniStyle.accent)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
        .accessibilityValue("\(dayTasks.count) tasks")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    // Selected day
    
    private var dayList: some View {
        let dayTasks = tasks(on: selectedDay)
        let isToday = calendar.isDate(selectedDay, inSameDayAs: today)
        
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(isToday ? "TODAY" : selectedDay.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()).uppercased())
                    .font(Theme.mono(11))
                    .tracking(0.9)
                    .foregroundStyle(isToday ? MiniStyle.amber : MiniStyle.textSoft)
                Spacer()
                if !dayTasks.isEmpty {
                    Text("\(dayTasks.count)")
                        .font(Theme.mono(11))
                        .foregroundStyle(MiniStyle.textMuted)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
            
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(dayTasks, id: \.miniID) { task in
                        row(task, isToday: isToday)
                    }
                }
            }
        }
    }
    
    private func row(_ task: NoteTask, isToday: Bool) -> some View {
        let done = task.task.checked
        
        return HStack(alignment: .center, spacing: 8) {
            Text(task.task.time?.miniLabel ?? "")
                .font(Theme.mono(10))
                .foregroundStyle(done ? Color.white.opacity(0.4) : (isToday ? MiniStyle.amber : MiniStyle.textSoft))
                .frame(width: 40, alignment: .trailing)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.task.text)
                    .font(Theme.ui(13))
                    .fontWeight(.semibold)
                    .foregroundStyle(done ? Color.white.opacity(0.5) : Color.white)
                    .strikethrough(done, color: Color.white.opacity(0.5))
                    .lineLimit(1)
                Text(task.noteName)
                    .font(Theme.mono(10))
                    .foregroundStyle(done ? Color.white.opacity(0.35) : MiniStyle.accent)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(done ? Color.white.opacity(0.04) : MiniStyle.accent.opacity(0.16),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .leading) {
                UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, style: .continuous)
                    .fill(done ? Color.white.opacity(0.2) : MiniStyle.accent)
                    .frame(width: 3)
            }
        }
    }
}
