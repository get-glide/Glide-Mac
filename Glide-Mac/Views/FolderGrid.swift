//
//  FolderGrid.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/7/26.
//

import SwiftUI

struct FolderGrid: View {
    let notes: [(name: String, open: Int, done: Int)]
    let onOpen: (String) -> Void
    
    private let columns = [GridItem(.adaptive(minimum: 180), spacing: Theme.gap)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Theme.gap) {
                ForEach(notes, id: \.name) { note in
                    GlideTile {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(note.name)
                                .font(Theme.ui(14.5))
                                .foregroundStyle(Theme.label)
                            Text(countsLabel(note))
                                .font(Theme.mono(11))
                                .foregroundStyle(Theme.labelTertiary)
                        }
                    }
                    .contentShape(Rectangle())
                    .pressable { onOpen(note.name) }
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceApp)
    }
    
    private func countsLabel(_ note: (name: String, open: Int, done: Int)) -> String {
        if note.open == 0 && note.done == 0 { return "No tasks" }
        return "\(note.open) open · \(note.done) done"
    }
}
