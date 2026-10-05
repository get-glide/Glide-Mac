//
//  MiniStyle.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/4/26.
//

//
//  MiniStyle.swift
//  Glide-Mac
//

import SwiftUI
import GlideCore

// Colors, sizes and shared pieces used only by the menu bar mini window.
//
// Kept separate from `Theme` so the mini's indigo look can change without
// touching the main window's palette.
enum MiniStyle {
    // Fixed size so switching between views never resizes the popover.
    static let width: CGFloat = 360
    static let height: CGFloat = 660
    
    // Surfaces
    
    static let chrome    = Color(hex: 0x181B45)
    static let page      = Color(hex: 0x121320)
    static let panel     = Color(hex: 0x1A1D36)
    static let panelLine = Color(hex: 0x2E3252)
    static let selected  = Color(hex: 0x2B2F5A)
    
    // Text
    
    static let text      = Color(hex: 0xECEDF7)
    static let textSoft  = Color(hex: 0xC9CDF5)
    static let textMuted = Color(hex: 0xA3A8D6)
    static let textFaint = Color(hex: 0x8388AD)
    static let marker    = Color(hex: 0x4A4E72)
    
    // Accents
    
    static let accent = Color(hex: 0x8E9AF5)
    static let amber  = Color(hex: 0xF2A65A)
    static let now    = Color(hex: 0xFF6B5E)
    
    // Overlays
    
    static let glass       = Color.black.opacity(0.28)
    static let glassBorder = Color.white.opacity(0.08)
    static let card        = Color.white.opacity(0.05)
    
    // Indigo behind the header that fades to near-black by 150pt.
    
    // Stops are computed from point values instead of percentages so the fade
    // lands in the same place in all three views.
    static let background = LinearGradient(
        stops: [
            .init(color: chrome, location: 0),
            .init(color: chrome, location: 44 / height),
            .init(color: page, location: 150 / height),
            .init(color: page, location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension NoteTask {
    // Stable identity for SwiftUI lists.
    
    // `NoteTask` lives in GlideCore and isn't `Identifiable`. Note name plus line
    // index is unique, and adding it here avoids changing Core.
    var miniID: String { "\(noteName)#\(lineIndex)" }
}

extension TaskTime {
    // Compact 12-hour label that drops ":00", such as "7p", "10a" or "11:59p".
    var miniLabel: String {
        let suffix = hour < 12 ? "a" : "p"
        let h12 = hour % 12 == 0 ? 12 : hour % 12
        return minute == 0 ? "\(h12)\(suffix)" : "\(h12):\(String(format: "%02d", minute))\(suffix)"
    }
    
    var minutesFromMidnight: Int { hour * 60 + minute }
}

// Dark translucent pill used behind every control in the mini header.
struct MiniGlass<Content: View>: View {
    var radius: CGFloat = 15
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .background(MiniStyle.glass, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(MiniStyle.glassBorder, lineWidth: 1)
            )
    }
}


struct MiniCheckbox: View {
    let checked: Bool
    var size: CGFloat = 17
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(checked ? MiniStyle.accent : .clear)
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(checked ? .clear : Color.white.opacity(0.35), lineWidth: 1.5)
            )
            .overlay {
                if checked {
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.55, weight: .heavy))
                        .foregroundStyle(MiniStyle.page)
                }
            }
            .frame(width: size, height: size)
    }
}
