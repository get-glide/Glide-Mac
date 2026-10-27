//
//  TopBar.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
//

import SwiftUI
import GlideCore

struct TopBar: View {
    let layout: TimelineLayout
    let route: Route
    let openTabs: [String]
    let onRoute: (Route) -> Void
    let onSelectTab: (String) -> Void
    let onCloseTab: (String) -> Void
    let onDeleteNote: (String) -> Void
    let onToggleSidebar: () -> Void
    let onNewNote: () -> Void
    let onQuickOpen: () -> Void
    let onSettings: () -> Void
    
    @Environment(\.openURL) private var openURL
    
    private static let feedbackURL = (Bundle.main.object(forInfoDictionaryKey: "GlideFeedbackURL") as? String)
        .flatMap { URL(string: $0) }
    
    var body: some View {
        HStack(spacing: 10) {
            TimelineColumn(layout: layout) {
                HStack(spacing: 16) {
                    Color.clear.frame(width: 72)
                    glidePill
                }
            }
            
            iconButton("sidebar.left", help: layout.visible ? "Hide timeline" : "Show timeline",
                       muted: layout.visible, action: onToggleSidebar)
            .keyboardShortcut("s", modifiers: [.control, .command])
            iconButton("square.and.pencil", help: "New note", action: onNewNote)
                .keyboardShortcut("n", modifiers: .command)
            tabStrip
            labelButton("magnifyingglass", "Search", hint: "⌘P", width: 220, muted: true, action: onQuickOpen)
                .keyboardShortcut("p", modifiers: .command)
            if let url = Self.feedbackURL {
                labelButton("bubble.left", "Feedback") { openURL(url) }
            }
            iconButton("gearshape", help: "Settings", action: onSettings)
                .keyboardShortcut(",", modifiers: .command)
        }
        .padding(.trailing, 12)
        .frame(height: 52)
    }
    
    private var glidePill: some View {
        GlassPill {
            HStack(spacing: 2) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 13, weight: .semibold))
                Text("GLIDE")
                    .font(Theme.display(15))
                    .tracking(0.9)
                    .padding(.leading, 6)
                    .padding(.trailing, 8)
                routeButton(.folder, icon: "book", help: "All notes")
                routeButton(.tasks, icon: "checkmark.square", help: "Tasks")
            }
            .foregroundStyle(Color.white)
            .padding(.leading, 12)
            .padding(.trailing, 3)
            .frame(height: 34)
        }
        .fixedSize()
    }
    
    private func routeButton(_ value: Route, icon: String, help: String) -> some View {
        let isOn = route == value
        return Button { onRoute(value) } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isOn ? Color.white : Theme.chromeText)
                .frame(width: 30, height: 26)
                .background(isOn ? Color.white.opacity(0.16) : .clear, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .help(help)
        .accessibilityLabel(help)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
    
    private var tabStrip: some View {
        GlassPill {
            HStack(spacing: 2) {
                ForEach(openTabs, id: \.self) { name in
                    TabChip(name: name, isActive: route == .note(name),
                            onSelect: { onSelectTab(name) }, onClose: { onCloseTab(name) },
                            onDelete: { onDeleteNote(name) })
                }
                Button(action: onQuickOpen) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.chromeText)
                        .frame(width: 28, height: 26)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .help("Open a note in a new tab")
                .accessibilityLabel("New tab")
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 3)
            .frame(height: 34)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
    }
    
    private func iconButton(_ icon: String, help: String, muted: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            GlassPill {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(muted ? Theme.chromeText : Color.white)
                    .frame(width: 34, height: 34)
            }
        }
        .buttonStyle(.plain)
        .help(help)
        .accessibilityLabel(help)
    }
    
    private func labelButton(_ icon: String, _ title: String, hint: String? = nil, width: CGFloat? = nil,
                             muted: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            GlassPill {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                    Text(title)
                        .font(Theme.ui(13))
                        .fontWeight(muted ? .regular : .medium)
                        .frame(maxWidth: width == nil ? nil : .infinity, alignment: .leading)
                    if let hint {
                        Text(hint).font(Theme.mono(11))
                    }
                }
                .foregroundStyle(muted ? Theme.chromeText : Color.white)
                .padding(.leading, 12)
                .padding(.trailing, 14)
                .frame(width: width, height: 34)
            }
        }
        .buttonStyle(.plain)
        .fixedSize()
        .help(title)
    }
}

private struct TabChip: View {
    let name: String
    let isActive: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: onSelect) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(Theme.accent)
                        .frame(width: 7, height: 7)
                    Text(name)
                        .font(Theme.ui(13))
                        .fontWeight(isActive ? .semibold : .regular)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .padding(.leading, 12)
                .padding(.trailing, 4)
                .frame(height: 26)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isActive ? .isSelected : [])
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .opacity(isActive ? 0.9 : 0.55)
                    .frame(width: 22, height: 22)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 2)
            .help("Close \(name)")
            .accessibilityLabel("Close \(name)")
        }
        .foregroundStyle(isActive ? Color.white : Theme.chromeText)
        .frame(minWidth: 90, idealWidth: 190, maxWidth: 190)
        .background(isActive ? Color.white.opacity(0.16) : .clear, in: Capsule())
        .contextMenu {
            Button("Delete Note", role: .destructive, action: onDelete)
                .disabled(DefaultNote(rawValue: name) != nil)
        }
    }
}
