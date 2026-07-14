//
//  ContentView.swift
//  Glide-Mac
//
//  Created by Aarnav on 6/24/26.
//

import SwiftUI
import GlideCore

struct ContentView: View{
    private let store = try! NoteStore.makeDefault()
    
    @State private var noteNames: [String] = []
    @State private var selectedNote: String?
    @State private var noteContent: String = ""
    
    var body: some View{
        NavigationSplitView {
            List(noteNames, id: \.self, selection: $selectedNote) { name in
                Text(name)
            }
        }detail: {
                Text(noteContent)
            }
        .onAppear{
            print("Glide folder:", store.directory.path)
            try? store.createDefaultNotesIfNeeded()
            noteNames = (try? store.listNotes()) ?? []
        }
        .onChange(of: selectedNote){
            if let selectedNote{
                noteContent = (try? store.read(selectedNote)) ?? ""
            }
        }
        }
    }


