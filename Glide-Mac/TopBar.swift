//
//  TopBar.swift
//  Glide-Mac
//
//  Created by Aarnav on 8/10/26.
//

import SwiftUI

struct TopBar: View {
    @State private var searchText: String = ""
    @FocusState private var searchFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "paperplane.fill")
                .foregroundStyle(Theme.primary)
            
            Text("GLIDE")
                .font(Theme.display(16))
                .foregroundStyle(Theme.textStrong)
                .tracking(2)
            
            HStack(spacing: 4) {
                Image(systemName: "book")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.primary)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Theme.primaryTint)
                    )
                Image(systemName: "checkmark.app")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textFaint)
                    .frame(width: 28, height: 28)
            }
            .padding(.leading, 20)
            .overlay(
                Rectangle()
                    .fill(Theme.borderSoft)
                    .frame(width: 1, height: 20),
                alignment: .leading
            )
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.textFaint)
                TextField("Search notes, tasks, decks", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(Theme.ui(13))
                    .foregroundStyle(Theme.textBody)
                    .focused($searchFocused)
                if !searchFocused {
                    Text("⌘K")
                        .font(Theme.mono(12))
                        .foregroundStyle(Theme.textFaint)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(width: searchFocused ? 320 : 180)
            .background(Theme.surfaceSunken)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .animation(.easeInOut(duration: 0.2), value: searchFocused)
            
            Image(systemName: "moon")
                .foregroundStyle(Theme.textFaint)
            Image(systemName: "gearshape")
                .foregroundStyle(Theme.textFaint)
        }
        .font(.system(size: 16))
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Theme.surfaceCard)
    }
}

#Preview {
    TopBar()
}
