//
//  Theme.swift
//  Glide-Mac
//
//  Created by Aarnav on 8/10/26.
//

import SwiftUI

extension Color {
    init(hex: UInt) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

enum Theme {
    static func display(_ size: CGFloat) -> Font {
        .custom("Geist", size: size).weight(.bold)
    }
    static func ui(_ size: CGFloat) -> Font {
        .custom("Geist", size: size)
    }
    static func mono(_ size: CGFloat) -> Font {
        .custom("Geist Mono", size: size)
    }
    
    static let surfaceApp  = Color(hex: 0x121320)
    static let surfaceTile = Color(hex: 0x1D2038)
    static let separator   = Color(hex: 0x23263C)
    
    static let label           = Color(hex: 0xECEDF7)
    static let labelSecondary  = Color(hex: 0xA3A8D6)
    static let labelTertiary   = Color(hex: 0x8388AD)
    static let labelQuaternary = Color(hex: 0x4A4E72)
    static let prose           = Color(hex: 0xC9CCE4)
    static let accent          = Color(hex: 0x8E9AF5)
    
    static let chrome      = Color(hex: 0x181B45)
    static let chromeText  = Color(hex: 0xC9CDF5)
    static let amber       = Color(hex: 0xF2A65A)
    static let now         = Color(hex: 0xFF6B5E)
    static let panel       = Color(hex: 0x1A1D36)
    static let panelLine   = Color(hex: 0x2E3252)
    static let selected    = Color(hex: 0x2B2F5A)
    static let glass       = Color.black.opacity(0.28)
    static let glassBorder = Color.white.opacity(0.08)
    static let card        = Color.black.opacity(0.22)
    
    static let tileRadius: CGFloat  = 10
    static let tilePadding: CGFloat = 14
    static let gap: CGFloat         = 10
    static let barHeight: CGFloat   = 36
    
    static let timelineDefault: Double = 272
    static let timelineMin: Double     = 244
    static let timelineMax: Double     = 420
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func pressable(action: @escaping () -> Void) -> some View {
        modifier(PressableTap(action: action))
    }
}

private struct PressableTap: ViewModifier {
    @State private var isPressed = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .opacity(isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}

struct GlassPill<Content: View>: View {
    var radius: CGFloat = 17
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .background(Theme.glass, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Theme.glassBorder, lineWidth: 1)
            )
    }
}
