//
//  NotebookGrid.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/7/26.
//

import SwiftUI

struct NotebookGrid: View {
    let entries: [NotebookEntry]
    let onOpen: (String) -> Void
    
    private let columns = [GridItem(.adaptive(minimum: 180), spacing: Theme.gap)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Theme.gap) {
                ForEach(entries) { entry in
                    GlideTile {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(entry.name)
                                .font(Theme.ui(14.5))
                                .foregroundStyle(Theme.label)
                            Text(countsLabel(entry))
                                .font(Theme.mono(11))
                                .foregroundStyle(Theme.labelTertiary)
                        }
                    }
                    .contentShape(Rectangle())
                    .pressable { onOpen(entry.name) }
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceApp)
    }
    
    private func countsLabel(_ entry: NotebookEntry) -> String {
        if entry.open == 0 && entry.done == 0 { return "No tasks" }
        return "\(entry.open) open · \(entry.done) done"
    }
}
