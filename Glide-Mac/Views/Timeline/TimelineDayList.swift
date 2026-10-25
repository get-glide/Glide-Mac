//
//  TimelineDayList.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
//

import SwiftUI
import GlideCore

struct TimelineDayList: View {
    let day: Date
    let tasks: [NoteTask]
    let onOpen: (String) -> Void
    @AppStorage("use24HourTime") private var use24Hour = false
    
    var body: some View {
        let isToday = Calendar.current.isDateInToday(day)
        
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(isToday ? "TODAY" : day.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()).uppercased())
                    .font(Theme.mono(11))
                    .fontWeight(.semibold)
                    .tracking(0.9)
                    .foregroundStyle(isToday ? Theme.amber : Theme.chromeText)
                Spacer()
                if !tasks.isEmpty {
                    Text("\(tasks.count)")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.chromeText)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
            
            if tasks.isEmpty {
                Text("Nothing scheduled")
                    .font(Theme.ui(13))
                    .foregroundStyle(Theme.chromeText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.14), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    )
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(tasks, id: \.railID) { task in
                            HStack(alignment: .top, spacing: 8) {
                                Text(task.task.time?.railLabel(use24Hour: use24Hour) ?? "")
                                    .font(Theme.mono(10))
                                    .foregroundStyle(task.task.checked ? Color.white.opacity(0.4) : (isToday ? Theme.amber : Theme.chromeText))
                                    .frame(width: 40, alignment: .trailing)
                                    .padding(.top, 10)
                                TaskCard(task: task, titleSize: 14, onOpen: onOpen)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.never)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
