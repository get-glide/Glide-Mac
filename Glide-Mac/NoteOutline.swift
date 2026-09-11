//
//  NoteOutline.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/8/26.
//

import SwiftUI

struct OutlineItem: Identifiable {
    let id = UUID()
    let title: String
    let level: Int
}

struct MockOutline {
    static let items: [OutlineItem] = [
        .init(title: "Recursion", level: 0),
        .init(title: "Base case", level: 1),
        .init(title: "Call stack", level: 1),
        .init(title: "Tail calls", level: 1),
        .init(title: "To do", level: 0),
    ]
}

struct NoteOutline: View {
    let items: [OutlineItem]
    
    var body: some View {
        GlideTile {
            VStack(alignment: .leading, spacing: 7) {
                ForEach(items) { item in
                    Text(item.title)
                        .font(Theme.ui(12.5))
                        .foregroundStyle(item.level == 0 ? Theme.label : Theme.labelSecondary)
                        .padding(.leading, item.level == 0 ? 0 : 12)
                }
            }
        }
        .frame(width: 146, alignment: .topLeading)
    }
}
