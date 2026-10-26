//
//  TimelineHelpers.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
//

import Foundation
import GlideCore

extension NoteTask {
    var railID: String { "\(noteName)#\(lineIndex)" }
}

extension TaskTime {
    var railMinutes: Int { hour * 60 + minute }
    
    func railLabel(use24Hour: Bool) -> String {
        if use24Hour { return String(format: "%d:%02d", hour, minute) }
        let suffix = hour < 12 ? "a" : "p"
        let h12 = hour % 12 == 0 ? 12 : hour % 12
        return minute == 0 ? "\(h12)\(suffix)" : "\(h12):\(String(format: "%02d", minute))\(suffix)"
    }
}

extension Array where Element == NoteTask {
    func groupedByDay(_ calendar: Calendar = .current) -> [Date: [NoteTask]] {
        var result: [Date: [NoteTask]] = [:]
        for task in self {
            guard let due = task.task.dueDate else { continue }
            result[calendar.startOfDay(for: due), default: []].append(task)
        }
        return result.mapValues { $0.sorted(by: railOrder) }
    }
}

private func railOrder(_ a: NoteTask, _ b: NoteTask) -> Bool {
    switch (a.task.time, b.task.time) {
    case let (x?, y?):
        if x.railMinutes != y.railMinutes { return x.railMinutes < y.railMinutes }
    case (_?, nil): return true
    case (nil, _?): return false
    default: break
    }
    if a.noteName != b.noteName { return a.noteName < b.noteName }
    return a.lineIndex < b.lineIndex
}

extension Calendar {
    func days(of component: Calendar.Component, containing date: Date = .now) -> [Date] {
        guard let interval = dateInterval(of: component, for: date) else { return [] }
        var days: [Date] = []
        var day = interval.start
        while day < interval.end {
            days.append(day)
            guard let next = self.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return days
    }
}
