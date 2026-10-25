//
//  NewNotePanel.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/24/26.
//

import SwiftUI

struct NewNotePanel: View {
    let existing: [String]
    let onCreate: (String) -> Bool
    let onClose: () -> Void
    
    @State private var name = ""
    @State private var error: String?
    @FocusState private var focused: Bool
    
    var body: some View {
        let field = RoundedRectangle(cornerRadius: 8, style: .continuous)
        let card = RoundedRectangle(cornerRadius: 14, style: .continuous)
        
        ZStack(alignment: .top) {
            Color.black.opacity(0.45)
                .onTapGesture(perform: onClose)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("New note")
                    .font(Theme.ui(16))
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.label)
                
                TextField("Note name", text: $name)
                    .textFieldStyle(.plain)
                    .font(Theme.ui(14))
                    .foregroundStyle(Theme.label)
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(Theme.surfaceApp, in: field)
                    .overlay(field.stroke(error == nil ? Theme.panelLine : Theme.now, lineWidth: 1))
                    .focused($focused)
                    .onSubmit(create)
                    .onExitCommand(perform: onClose)
                    .onChange(of: name) { error = nil }
                
                if let error {
                    Text(error)
                        .font(Theme.ui(12))
                        .foregroundStyle(Theme.now)
                }
                
                HStack(spacing: 8) {
                    Spacer()
                    Button("Cancel", action: onClose)
                        .buttonStyle(PanelButtonStyle(primary: false))
                        .keyboardShortcut(.cancelAction)
                    Button("Create", action: create)
                        .buttonStyle(PanelButtonStyle(primary: true))
                }
            }
            .padding(16)
            .frame(width: 360)
            .background(Theme.panel, in: card)
            .overlay(card.stroke(Theme.panelLine, lineWidth: 1))
            .shadow(color: .black.opacity(0.5), radius: 25, y: 20)
            .padding(.top, 96)
        }
        .onAppear { DispatchQueue.main.async { focused = true } }
    }
    
    private func create() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        error = problem(with: trimmed) ?? (onCreate(trimmed) ? nil : "Couldn't create the note.")
    }
    
    private func problem(with name: String) -> String? {
        if name.isEmpty { return "Enter a name." }
        if name.hasPrefix(".") || name.contains(where: { "/:".contains($0) }) {
            return "Names can't contain / or : or start with a dot."
        }
        if existing.contains(where: { $0.caseInsensitiveCompare(name) == .orderedSame }) {
            return "A note with that name already exists."
        }
        return nil
    }
}

private struct PanelButtonStyle: ButtonStyle {
    let primary: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.ui(13))
            .fontWeight(primary ? .semibold : .regular)
            .foregroundStyle(primary ? Theme.surfaceApp : Theme.labelSecondary)
            .padding(.horizontal, 14)
            .frame(height: 30)
            .background(primary ? Theme.accent : .clear, in: Capsule())
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
