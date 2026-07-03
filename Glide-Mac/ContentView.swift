//
//  ContentView.swift
//  Glide-Mac
//
//  Created by Pranay Venkat Aluri on 7/2/26.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = "Hello world"

    var body: some View {
        GlideTextView(text: $text)
            .frame(minWidth: 400, minHeight: 300)
    }
}
