//
//  AddTaskField.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/24/26.
//

import SwiftUI
import GlideCore

struct AddTaskField: View {
    let target: String
    let onAdd: (String) -> Void
    
    @State private var text = ""
    
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.chromeText)
            TextField("Add a task to \(target)", text: $text)
                .textFieldStyle(.plain)
                .font(Theme.ui(13))
                .foregroundStyle(Theme.label)
                .onSubmit(submit)
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(Theme.card, in: shape)
        .overlay(shape.stroke(Theme.glassBorder, lineWidth: 1))
    }
    
    private func submit() {
        let value = text.trimmingCharacters(in: .whitespaces)
        guard !value.isEmpty else { return }
        onAdd(value)
        text = ""
    }
}

enum TaskEntry {
    static func line(from text: String, defaultDue: Date? = nil) -> String {
        var line = text.trimmingCharacters(in: .whitespaces)
        if case .note = parseLine(line) { line = "[] " + line }
        return finalizeLine(line, defaultDue: defaultDue)
    }
}

extension String {
    func appendingLine(_ line: String) -> String {
        isEmpty || hasSuffix("\n") ? self + line : self + "\n" + line
    }
}
