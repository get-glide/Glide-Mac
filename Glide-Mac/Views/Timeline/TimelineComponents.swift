//
//  TimelineComponents.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
//

import SwiftUI
import GlideCore

enum RailMetrics {
    static let time: CGFloat = 34
    static let node: CGFloat = 16
}

struct RailRow<Time: View, Node: View, Content: View>: View {
    var alignment: VerticalAlignment = .center
    @ViewBuilder var time: Time
    @ViewBuilder var node: Node
    @ViewBuilder var content: Content
    
    var body: some View {
        HStack(alignment: alignment, spacing: 0) {
            time.frame(width: RailMetrics.time, alignment: .trailing)
            node.frame(width: RailMetrics.node)
            content.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TaskCard: View {
    let task: NoteTask
    var isNext = false
    var titleSize: CGFloat = 15
    let onOpen: (String) -> Void
    
    private let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
    
    var body: some View {
        let done = task.task.checked
        
        Button { onOpen(task.noteName) } label: {
            VStack(alignment: .leading, spacing: 3) {
                if isNext {
                    Text("UP NEXT")
                        .font(Theme.mono(10))
                        .fontWeight(.semibold)
                        .tracking(0.8)
                        .foregroundStyle(Theme.amber)
                }
                Text(task.task.text)
                    .font(Theme.ui(titleSize))
                    .fontWeight(.semibold)
                    .foregroundStyle(done ? Color.white.opacity(0.5) : Color.white)
                    .strikethrough(done, color: Color.white.opacity(0.5))
                    .lineLimit(1)
                Text(task.noteName)
                    .font(Theme.mono(10))
                    .foregroundStyle(done ? Color.white.opacity(0.4) : Theme.accent)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(done ? Color.white.opacity(0.04) : Theme.accent.opacity(0.16), in: shape)
            .overlay(alignment: .leading) {
                UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, style: .continuous)
                    .fill(done ? Color.white.opacity(0.2) : Theme.accent)
                    .frame(width: 3)
            }
            .overlay {
                if isNext {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Theme.amber.opacity(0.6), lineWidth: 1.5)
                        .padding(-2)
                }
            }
            .contentShape(shape)
        }
        .buttonStyle(PressableButtonStyle())
        .help("Open \(task.noteName)")
    }
}

struct DayDots: View {
    let tasks: [NoteTask]
    let faded: Bool
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(tasks.prefix(3), id: \.railID) { task in
                Circle()
                    .fill(faded || task.task.checked ? Color.white.opacity(0.3) : Theme.accent)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 4)
    }
}
