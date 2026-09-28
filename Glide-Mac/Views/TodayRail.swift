//
//  TodayRail.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/8/26.
//

import SwiftUI
import GlideCore

struct RailTask: Identifiable {
    let id = UUID()
    let text: String
    let time: TaskTime
    let checked: Bool
    var minutes: Int = 30
}

extension RailTask {
    init?(_ noteTask: NoteTask) {
        guard let time = noteTask.task.time else { return nil }
        self.text = noteTask.task.text
        self.time = time
        self.checked = noteTask.task.checked
    }
}

struct TodayRail: View {
    let tasks: [RailTask]
    
    private var startHour: Int {
        let earliest = tasks.map { $0.time.hour }.min() ?? 9
        return max(0, earliest - 1)
    }

    private var endHour: Int {
        let latest = tasks.map { $0.time.hour }.max() ?? 18
        return min(23, max(latest + 1, startHour + 6))
    }
    
    private let hourHeight: CGFloat = 60
    private let topInset: CGFloat = 10
    
    var body: some View {
        if tasks.isEmpty {
            Text("Nothing scheduled")
                .font(Theme.ui(12.5))
                .foregroundStyle(Theme.labelTertiary)
                .padding(.top, 24)
                .padding(.leading, 30)
        } else {
            ScrollView {
                ZStack(alignment: .topLeading) {
                    hourGrid
                    ForEach(tasks) { task in
                        taskBlock(task)
                            .offset(y: yOffset(for: task.time))
                            .padding(.leading, 30)
                    }
                }
                .padding(.top, topInset)
                .frame(height: CGFloat(endHour - startHour) * hourHeight + topInset, alignment: .top)
            }
        }
    }
    
    private var hourGrid: some View {
        ForEach(startHour...endHour, id: \.self) { hour in
            Text(String(format: "%02d", hour))
                .font(Theme.mono(10))
                .foregroundStyle(Theme.labelTertiary)
                .offset(y: CGFloat(hour - startHour) * hourHeight + topInset - 5)
        }
    }
    
    private func yOffset(for time: TaskTime) -> CGFloat {
        let minutesFromStart = (time.hour - startHour) * 60 + time.minute
        return CGFloat(minutesFromStart) / 60 * hourHeight + topInset
    }
    
    @ViewBuilder
    private func taskBlock(_ task: RailTask) -> some View {
        let height = max(CGFloat(task.minutes) / 60 * hourHeight, 22)
        GlideBlockTile(height: height) {
            Text(task.text)
                .font(Theme.ui(height < 28 ? 12 : 13.5))
                .foregroundStyle(task.checked ? Theme.labelTertiary : Theme.label)
                .lineLimit(1)
        }
    }
}
