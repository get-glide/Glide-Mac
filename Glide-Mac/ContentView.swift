//
//  ContentView.swift
//  Glide-Mac
//
//  Created by Pranay Venkat Aluri on 7/2/26.
//

import SwiftUI
import GlideCore

struct ContentView: View{
    private let store = try! NoteStore.makeDefault()
    
    @State private var noteNames: [String] = []
    @State private var selectedNote: String?
    @State private var noteContent: String = "Hello world"
    
    var body: some View{
        NavigationSplitView {
            List(noteNames, id: \.self, selection: $selectedNote) { name in
                Text(name)
            }
        } detail: {
            GlideTextView(text: $noteContent)
                .frame(minWidth: 400, minHeight: 300)
        }
        .onAppear {
            print("Glide folder:", store.directory.path)
            try? store.createDefaultNotesIfNeeded()
            noteNames = (try? store.listNotes()) ?? []
        }
        .onChange(of: selectedNote) {
            if let selectedNote {
                noteContent = (try? store.read(selectedNote)) ?? ""
            }
        }
    }
}
