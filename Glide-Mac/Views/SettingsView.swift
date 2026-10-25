import SwiftUI
import AppKit

struct SettingsView: View {
    let folder: URL
    let onClose: () -> Void
    
    @AppStorage("use24HourTime") private var use24Hour = false
    @AppStorage("showMenuBarExtra") private var showMenuBar = true
    
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    
    var body: some View {
        let card = RoundedRectangle(cornerRadius: 16, style: .continuous)
        
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.3)
                .onTapGesture(perform: onClose)
            
            VStack(alignment: .leading, spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        section("Notes folder") { folderRow }
                        section("General") {
                            row("Time format") { timeFormatPicker }
                            row("Show in menu bar") {
                                Toggle("Show in menu bar", isOn: $showMenuBar)
                                    .labelsHidden()
                                    .toggleStyle(.switch)
                                    .tint(Theme.accent)
                            }
                            row("Unfinished tasks roll over") { tag("Midnight") }
                        }
                        section("Shortcuts") {
                            row("Search") { tag("⌘P") }
                            row("New note") { tag("⌘N") }
                            row("Show or hide timeline") { tag("⌃⌘S") }
                            row("Settings") { tag("⌘,") }
                        }
                        section("Syntax") {
                            row("Task") { tag("[] task") }
                            row("Done") { tag("[x] task") }
                            row("Time") { tag("9:00am task") }
                            row("Heading") { tag("# Heading") }
                            row("Repeats") { tag("@daily @weekly @weekday @monthly") }
                            row("Repeats on a day") { tag("@mon … @sun") }
                        }
                        if let version {
                            Text("Glide \(version)")
                                .font(Theme.mono(11))
                                .foregroundStyle(Theme.labelTertiary)
                        }
                    }
                    .padding(16)
                }
                .scrollIndicators(.never)
            }
            .frame(width: 400)
            .frame(maxHeight: 560)
            .background(Theme.panel, in: card)
            .overlay(card.stroke(Theme.panelLine, lineWidth: 1))
            .shadow(color: .black.opacity(0.5), radius: 25, y: 20)
            .padding(.top, 60)
            .padding(.trailing, 12)
        }
    }
    
    private var header: some View {
        HStack {
            Text("Settings")
                .font(Theme.ui(16))
                .fontWeight(.semibold)
                .foregroundStyle(Theme.label)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.labelSecondary)
                    .frame(width: 26, height: 26)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.cancelAction)
            .help("Close")
            .accessibilityLabel("Close settings")
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.panelLine).frame(height: 1)
        }
    }
    
    private var folderRow: some View {
        HStack(spacing: 8) {
            Text(folder.path(percentEncoded: false))
                .font(Theme.mono(12))
                .foregroundStyle(Theme.label)
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
                .background(Theme.surfaceApp, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .help(folder.path(percentEncoded: false))
            Button {
                NSWorkspace.shared.activateFileViewerSelecting([folder])
            } label: {
                Text("Show in Finder")
                    .font(Theme.ui(12))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .frame(height: 32)
                    .background(Color.white.opacity(0.1), in: Capsule())
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
    
    private var timeFormatPicker: some View {
        HStack(spacing: 2) {
            ForEach([false, true], id: \.self) { is24 in
                let isOn = use24Hour == is24
                Button { use24Hour = is24 } label: {
                    Text(is24 ? "24h" : "12h")
                        .font(Theme.ui(12))
                        .fontWeight(isOn ? .semibold : .regular)
                        .foregroundStyle(isOn ? Color.white : Theme.chromeText)
                        .padding(.horizontal, 10)
                        .frame(height: 24)
                        .background(isOn ? Theme.selected : .clear, in: Capsule())
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
        .padding(3)
        .background(Theme.surfaceApp, in: Capsule())
    }
    
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(Theme.mono(11))
                .fontWeight(.semibold)
                .tracking(0.9)
                .foregroundStyle(Theme.labelTertiary)
            content()
        }
    }
    
    private func row<Trailing: View>(_ label: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(Theme.ui(13))
                .foregroundStyle(Theme.label)
            Spacer(minLength: 0)
            trailing()
        }
        .frame(minHeight: 26)
    }
    
    private func tag(_ text: String) -> some View {
        Text(text)
            .font(Theme.mono(12))
            .foregroundStyle(Theme.label)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Theme.surfaceApp, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
