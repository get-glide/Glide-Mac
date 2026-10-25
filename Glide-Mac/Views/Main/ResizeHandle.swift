//
//  ResizeHandle.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
//

import SwiftUI

struct ResizeHandle: View {
    let layout: TimelineLayout
    @State private var dragStart: Double?
    
    var body: some View {
        Capsule()
            .fill(dragStart == nil ? Color.white.opacity(0.18) : Theme.accent)
            .frame(width: 4, height: 44)
            .frame(width: 10)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .pointerStyle(.columnResize)
            .highPriorityGesture(
                DragGesture(minimumDistance: 1, coordinateSpace: .global)
                    .onChanged { value in
                        let start = dragStart ?? layout.width
                        if dragStart == nil { dragStart = start }
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            layout.width = layout.clamp(start + value.translation.width)
                        }
                    }
                    .onEnded { _ in dragStart = nil }
            )
            .simultaneousGesture(
                TapGesture(count: 2).onEnded {
                    withAnimation(.snappy) { layout.width = Theme.timelineDefault }
                }
            )
            .accessibilityElement()
            .accessibilityLabel("Resize timeline")
            .accessibilityValue("\(Int(layout.width)) points")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: layout.width = layout.clamp(layout.width + 16)
                case .decrement: layout.width = layout.clamp(layout.width - 16)
                @unknown default: break
                }
            }
    }
}
