import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                Text("Settings")
                    .font(Theme.ui(14))
                    .foregroundStyle(Theme.label)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Theme.labelTertiary)
                }
                .buttonStyle(.plain)
            }
            .frame(height: Theme.barHeight)
            .padding(.horizontal, 16)
            
            ScrollView {
                VStack(spacing: 10) {
                    
                    GlideTile {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes folder")
                                .font(Theme.ui(13))
                                .foregroundStyle(Theme.labelSecondary)
                            
                            HStack {
                                Text("~/Documents/Glide")
                                    .font(Theme.mono(13))
                                    .foregroundStyle(Theme.label)
                                Spacer()
                                Text("Change")
                                    .font(Theme.ui(12.5))
                                    .foregroundStyle(Theme.labelSecondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Theme.separator, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    
                    GlideTile {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Day")
                                .font(Theme.ui(13))
                                .foregroundStyle(Theme.labelSecondary)
                            
                            settingsRow("Timeline starts", "09:00")
                            settingsRow("Timeline ends", "18:00")
                            settingsRow("Roll unfinished tasks over", "04:00")
                        }
                    }
                    
                    GlideTile {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Editor")
                                .font(Theme.ui(13))
                                .foregroundStyle(Theme.labelSecondary)
                            
                            settingsRow("Text size", "14pt")
                            settingsRow("Appearance", "Match system")
                        }
                    }
                    
                    GlideTile {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Syntax")
                                .font(Theme.ui(13))
                                .foregroundStyle(Theme.labelSecondary)
                                .padding(.bottom, 4)
                            
                            syntaxRow("~2h", "how long it takes")
                            syntaxRow("!fri", "when it is due")
                            syntaxRow(">chem", "which note it goes to")
                            syntaxRow("@daily", "repeats")
                        }
                    }
                }
                .padding(16)
            }
        }
        .frame(width: 380, height: 480)
        .background(Theme.surfaceApp)
    }
    
    private func settingsRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.ui(13.5))
                .foregroundStyle(Theme.label)
            Spacer()
            Text(value)
                .font(Theme.mono(13))
                .foregroundStyle(Theme.label)
        }
    }
    
    private func syntaxRow(_ token: String, _ meaning: String) -> some View {
        HStack {
            Text(token)
                .font(Theme.mono(13))
                .foregroundStyle(Theme.label)
                .frame(width: 70, alignment: .leading)
            Text(meaning)
                .font(Theme.ui(12.5))
                .foregroundStyle(Theme.labelTertiary)
        }
    }
}

#Preview {
    SettingsView()
}
