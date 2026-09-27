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

struct TodayRail: View {
    let tasks: [RailTask]
    
    private let startHour = 9
    private let endHour = 18
    private let hourHeight: CGFloat = 46
    private let topInset: CGFloat = 10
    
    var body: some View {
        if tasks.isEmpty {
            Text("Nothing scheduled")
                .font(Theme.ui(12.5))
                .foregroundStyle(Theme.labelTertiary)
                .padding(.top, 24)
                .padding(.leading, 30)
        } else {
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
