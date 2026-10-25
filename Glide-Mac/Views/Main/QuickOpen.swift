//
//  QuickOpen.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
//

import SwiftUI

struct QuickOpenResult {
    let noteName: String
    let line: String?
}

struct QuickOpen: View {
    @Binding var query: String
    let results: [QuickOpenResult]
    let openTabs: [String]
    var focus: FocusState<Bool>.Binding
    let onPick: (String) -> Void
    let onClose: () -> Void
    
    @State private var selection = 0
    
    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.45)
                .onTapGesture(perform: onClose)
            
            VStack(spacing: 0) {
                field
                Rectangle().fill(Theme.panelLine).frame(height: 1)
                list
                footer
            }
            .frame(width: 560)
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Theme.panelLine, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 25, y: 20)
            .padding(.top, 96)
        }
        .onChange(of: query) { selection = 0 }
    }
    
    private var field: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.labelSecondary)
            TextField("Search notes and text", text: $query)
                .textFieldStyle(.plain)
                .font(Theme.ui(16))
                .foregroundStyle(Theme.label)
                .focused(focus)
                .onSubmit { pick(selection) }
                .onKeyPress(.downArrow) {
                    selection = min(selection + 1, max(results.count - 1, 0))
                    return .handled
                }
                .onKeyPress(.upArrow) {
                    selection = max(selection - 1, 0)
                    return .handled
                }
                .onExitCommand(perform: onClose)
                .accessibilityLabel("Search notes and text")
            Text("esc")
                .font(Theme.mono(11))
                .foregroundStyle(Theme.labelTertiary)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }
    
    @ViewBuilder
    private var list: some View {
        if results.isEmpty {
            Text("No matches.")
                .font(Theme.ui(13))
                .foregroundStyle(Theme.labelSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 1) {
                        ForEach(Array(results.enumerated()), id: \.offset) { index, result in
                            row(result, isSelected: index == selection) { pick(index) }
                                .id(index)
                        }
                    }
                    .padding(6)
                }
                .frame(maxHeight: 360)
                .onChange(of: selection) { _, index in
                    proxy.scrollTo(index)
                }
            }
        }
    }
    
    private func row(_ result: QuickOpenResult, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: result.line == nil ? "doc.text" : "text.alignleft")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 14)
                VStack(alignment: .leading, spacing: 2) {
                    Text(highlighted(result.noteName, base: Theme.label))
                        .font(Theme.ui(14))
                        .fontWeight(.medium)
                    if let line = result.line {
                        Text(highlighted(snippet(line), base: Theme.labelTertiary))
                            .font(Theme.mono(11))
                    }
                }
                .lineLimit(1)
                Spacer()
                if openTabs.contains(result.noteName) {
                    Text("open")
                        .font(Theme.mono(10))
                        .foregroundStyle(Theme.labelTertiary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(isSelected ? Theme.selected : .clear,
                        in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func snippet(_ line: String) -> String {
        let text = line.trimmingCharacters(in: .whitespaces)
        guard let hit = text.range(of: trimmedQuery, options: .caseInsensitive),
              text.distance(from: text.startIndex, to: hit.lowerBound) > 40 else { return text }
        let start = text.index(hit.lowerBound, offsetBy: -20)
        return "…" + text[start...]
    }
    
    private func highlighted(_ text: String, base: Color) -> AttributedString {
        var result = AttributedString(text)
        result.foregroundColor = base
        guard !trimmedQuery.isEmpty else { return result }
        
        var searchStart = result.startIndex
        while searchStart < result.endIndex,
              let range = result[searchStart...].range(of: trimmedQuery, options: .caseInsensitive) {
            result[range].foregroundColor = Theme.label
            result[range].backgroundColor = Theme.accent.opacity(0.3)
            searchStart = range.upperBound
        }
        return result
    }
    
    private var footer: some View {
        HStack(spacing: 16) {
            Text("↑↓ move")
            Text("↩ open")
            Text("esc close")
            Spacer()
            if !trimmedQuery.isEmpty {
                Text(results.count == 1 ? "1 match" : "\(results.count) matches")
            }
        }
        .font(Theme.mono(11))
        .foregroundStyle(Theme.labelTertiary)
        .padding(.horizontal, 16)
        .frame(height: 34)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.panelLine).frame(height: 1)
        }
    }
    
    private func pick(_ index: Int) {
        guard results.indices.contains(index) else { return }
        onPick(results[index].noteName)
    }
}
