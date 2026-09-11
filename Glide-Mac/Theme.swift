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
        .custom("Bricolage Grotesque 24pt SemiCondensed", size: size)
    }
    static func ui(_ size: CGFloat) -> Font {
        .custom("Hanken Grotesk", size: size)
    }
    static func mono(_ size: CGFloat) -> Font {
        .custom("JetBrains Mono", size: size)
    }
    
    
    
    static let surfaceApp  = Color(hex: 0x16150F)
    static let surfaceTile = Color(hex: 0x1E1C14)
    static let separator   = Color(hex: 0x35322A)
    
    
    
    static let label           = Color(hex: 0xF0EDE3)
    static let labelSecondary  = Color(hex: 0x8A8577)
    static let labelTertiary   = Color(hex: 0x55524A)
    static let labelQuaternary = Color(hex: 0x4A4740)
    static let prose           = Color(hex: 0xCFCABA)
    
    
    
    static let tileRadius: CGFloat  = 10
    static let tilePadding: CGFloat = 14
    static let gap: CGFloat         = 10
    static let barHeight: CGFloat   = 36
    static let railWidth: CGFloat   = 214
    static let hourHeight: CGFloat  = 46
    
    
    
    static let surfaceCard   = surfaceTile
    static let surfaceSunken = surfaceTile
    static let borderSoft    = separator
    static let borderStrong  = labelTertiary
    static let textStrong    = label
    static let textBody      = prose
    static let textMuted     = labelSecondary
    static let textFaint     = labelTertiary
    static let primary       = label
    static let primaryTint   = surfaceTile
    static let tokenInk      = labelSecondary
    static let literal       = surfaceTile
    static let warning       = labelSecondary
    static let warningTint   = surfaceTile
    static let danger        = Color(hex: 0xC4623F)
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
