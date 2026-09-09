//
//  NotebookGrid.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/7/26.
//

import SwiftUI

struct NotebookGrid: View {
    let noteNames: [String]
    let onOpen: (String) -> Void
    
    private let columns = [GridItem(.adaptive(minimum: 180), spacing: Theme.gap)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Theme.gap) {
                ForEach(noteNames, id: \.self) { name in
                    GlideTile {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(name)
                                .font(Theme.ui(14.5))
                                .foregroundStyle(Theme.label)
                            Text("—")
                                .font(Theme.mono(11))
                                .foregroundStyle(Theme.labelTertiary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { onOpen(name) }
                }
            }
            .padding(14)
        }
    }
}
