//
//  NotebookSidebar.swift
//  Glide-Mac
//
//  Created by Aarnav on 8/10/26.
//

import SwiftUI
import GlideCore

struct NotebookSidebar: View {
    let noteNames: [String]
    let selectedNote: String
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("NOTEBOOKS")
                .font(Theme.ui(11))
                .foregroundStyle(Theme.textFaint)
                .tracking(1.5)
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            ForEach(noteNames, id: \.self) { name in
                SidebarRow(
                    name: name,
                    isSelected: name == selectedNote,
                    onTap: { onSelect(name) }
                )
            }
            
            Spacer()
        }
        .frame(width: 240)
        .background(Theme.surfaceCard)
    }
}

struct SidebarRow: View {
    let name: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(name)
                Spacer()
            }
            .font(Theme.ui(14))
            .foregroundStyle(isSelected ? Theme.primary : Theme.textBody)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Theme.primaryTint : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
    }
    
    private var icon: String {
        switch name {
        case DefaultNote.today.rawValue: return "sun.max"
        case DefaultNote.classes.rawValue: return "book"
        case DefaultNote.projects.rawValue: return "square.stack"
        case DefaultNote.completed.rawValue: return "checkmark"
        default: return "doc"
        }
    }
}

#Preview {
    ContentView()
}
