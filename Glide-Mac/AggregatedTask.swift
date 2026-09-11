//
//  AggregatedTask.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/10/26.
//

import Foundation
import GlideCore

struct AggregatedTask: Identifiable {
    let id = UUID()
    let text: String
    let sourceNote: String
    let time: TaskTime?
    var checked: Bool
}

protocol TaskAggregating {
    func allTasks() -> [AggregatedTask]
}

struct MockTaskAggregator: TaskAggregating {
    func allTasks() -> [AggregatedTask] {
        [
            AggregatedTask(text: "write Q3 brief", sourceNote: "Today", time: TaskTime(hour: 11, minute: 0), checked: false),
            AggregatedTask(text: "a3 recursion", sourceNote: "cs 2110", time: nil, checked: false),
            AggregatedTask(text: "reread slides", sourceNote: "cs 2110", time: nil, checked: true),
            AggregatedTask(text: "lab report", sourceNote: "chem", time: nil, checked: false),
            AggregatedTask(text: "ch. 7 problems", sourceNote: "chem", time: nil, checked: false),
            AggregatedTask(text: "pset 4", sourceNote: "physics", time: nil, checked: false),
            AggregatedTask(text: "email prof. ito", sourceNote: "Inbox", time: nil, checked: false),
        ]
    }
}
