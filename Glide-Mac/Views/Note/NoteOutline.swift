//
//  NoteOutline.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/8/26.
//

import SwiftUI
import GlideCore

struct OutlineItem: Identifiable {
    let id = UUID()
    let title: String
    let level: Int
}

struct NoteOutline: View {
    let text: String
    
    private var items: [OutlineItem] {
        text.components(separatedBy: "\n").compactMap { line in
            switch parseLine(line) {
            case .note(let text, let level):
                guard let level = level else { return nil }
                return OutlineItem(title: text, level: level - 1)
            case .task(let task):
                guard let level = task.headingLevel else { return nil }
                return OutlineItem(title: task.text, level: level - 1)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ForEach(items) { item in
                Text(item.title)
                    .font(Theme.ui(12.5))
                    .foregroundStyle(item.level == 0 ? Theme.label : Theme.labelSecondary)
                    .padding(.leading, item.level == 0 ? 0 : 12)
            }
        }
        .frame(width: 146, alignment: .topLeading)
        .padding(.leading, 24)
    }
}
