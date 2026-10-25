//
//  CalendarCard.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
//

import SwiftUI
import GlideCore

struct CalendarCard: View {
    let tasksByDay: [Date: [NoteTask]]
    @Binding var range: SidebarRange
    @Binding var selectedDay: Date
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    private var monthOpen: Bool { range == .month }
    private var today: Date { calendar.startOfDay(for: .now) }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }
    
    var body: some View {
        VStack(spacing: 2) {
            if monthOpen {
                monthGrid.transition(.opacity)
            } else {
                weekStrip.transition(.opacity)
            }
            expandButton
        }
        .padding(.top, 8)
        .padding(.horizontal, 4)
        .padding(.bottom, 2)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var weekStrip: some View {
        HStack(spacing: 2) {
            ForEach(calendar.days(of: .weekOfYear), id: \.self) { day in
                VStack(spacing: 4) {
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(Theme.mono(10))
                        .fontWeight(.semibold)
                        .foregroundStyle(day == today ? Theme.amber : Theme.chromeText)
                    dayNumber(day, size: 12, bold: true)
                    DayDots(tasks: tasksByDay[day] ?? [], faded: day < today)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
            }
        }
    }
    
    private var monthGrid: some View {
        let days = calendar.days(of: .month)
        let week = calendar.dateInterval(of: .weekOfYear, for: .now)
        let blanks = days.first.map { (calendar.component(.weekday, from: $0) - calendar.firstWeekday + 7) % 7 } ?? 0
        let tintBlanks = days.first.map { week?.contains($0) ?? false } ?? false
        
        return VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(Theme.mono(10))
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.chromeText)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(0..<blanks, id: \.self) { _ in
                    Color.clear
                        .frame(height: 34)
                        .background(tintBlanks ? Theme.amber.opacity(0.08) : .clear)
                }
                ForEach(days, id: \.self) { day in
                    monthCell(day, inWeek: week?.contains(day) ?? false)
                }
            }
        }
    }
    
    private func monthCell(_ day: Date, inWeek: Bool) -> some View {
        let isSelected = day == selectedDay
        let tasks = tasksByDay[day] ?? []
        
        return Button { selectedDay = day } label: {
            VStack(spacing: 3) {
                dayNumber(day, size: 11, bold: isSelected, ringed: isSelected)
                DayDots(tasks: tasks, faded: day < today)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(inWeek ? Theme.amber.opacity(0.08) : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
        .accessibilityValue("\(tasks.count) tasks")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private func dayNumber(_ day: Date, size: CGFloat, bold: Bool, ringed: Bool = false) -> some View {
        let isToday = day == today
        return Text(day.formatted(.dateTime.day()))
            .font(Theme.mono(size))
            .fontWeight(bold || isToday ? .semibold : .regular)
            .foregroundStyle(isToday ? Theme.surfaceApp : (day < today ? Color.white.opacity(0.45) : Color.white))
            .frame(width: 26, height: 26)
            .background(isToday ? Theme.amber : .clear, in: Circle())
            .overlay {
                if ringed && !isToday {
                    Circle().stroke(Theme.accent, lineWidth: 1.5)
                }
            }
    }
    
    private var expandButton: some View {
        Button {
            withAnimation(.snappy(duration: 0.25)) {
                range = monthOpen ? .week : .month
            }
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(monthOpen ? Theme.amber : Theme.chromeText)
                .rotationEffect(.degrees(monthOpen ? 180 : 0))
                .frame(width: 56, height: 22)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(monthOpen ? "Collapse to week" : "Expand to month")
        .accessibilityLabel(monthOpen ? "Collapse to week" : "Expand to month")
    }
}
