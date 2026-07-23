//
//  ContentView.swift
//  Glide-Mac
//
//  Created by Aarnav on 6/24/26.
//

import SwiftUI
import GlideCore

struct ContentView: View {
    private let store = try! NoteStore.makeDefault()
    
    @State private var noteNames: [String] = []
    @State private var selectedNote: String?
    @State private var noteContent: String = ""
    @State private var searchQuery: String = ""
    @State private var searchResults: [SearchResult] = []
    @State private var hoveredLine: String?
    
    var body: some View {
        NavigationSplitView {
            if searchQuery.isEmpty {
                List(noteNames, id: \.self, selection: $selectedNote) { name in
                    Text(name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(hoveredLine == name ? Color.secondary.opacity(0.15) : Color.clear)
                        )
                        .contentShape(Rectangle())
                        .onHover { isHovering in
                            hoveredLine = isHovering ? name : nil
                        }
                }
            } else {
                List(searchResults, id: \.line) { result in
                    Button {
                        selectedNote = result.noteName
                        searchQuery = ""
                    } label: {
                        VStack(alignment: .leading) {
                            Text(result.line)
                            Text(result.noteName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(hoveredLine == result.line ? Color.secondary.opacity(0.15) : Color.clear)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .onHover { isHovering in
                        hoveredLine = isHovering ? result.line : nil
                    }
                }
            }
        } detail: {
            Text(noteContent)
        }
        .onAppear {
            try? store.createDefaultNotesIfNeeded()
            noteNames = (try? store.listNotes()) ?? []
        }
        .onChange(of: selectedNote) {
            if let selectedNote {
                noteContent = (try? store.read(selectedNote)) ?? ""
            }
        }
        .searchable(text: $searchQuery)
        .onChange(of: searchQuery) {
            searchResults = (try? store.search(searchQuery)) ?? []
        }
    }
}
