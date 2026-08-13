//
//  ContentView.swift
//  Glide-Mac
//
//  Created by Pranay Venkat Aluri on 7/2/26.
//

import SwiftUI

struct ContentView: View {
    private let store = try! NoteStore.makeDefault()
    
    @State private var noteNames: [String] = []
    @State private var selectedNote: String = DefaultNote.today.rawValue
    @State private var noteText: String = ""
    
    var body: some View {
        GlideTextView(text: $text)
            .frame(minWidth: 400, minHeight: 300)
    }
}
