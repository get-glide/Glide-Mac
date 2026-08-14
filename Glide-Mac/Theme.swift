//
//  Theme.swift
//  Glide-Mac
//
//  Created by Aarnav on 8/10/26.
//

import SwiftUI

extension Color{
    //This is a Hex helper. Swift does not use hex codes by default so we need to use this to use hex codes. Once we have the light mode colors decided I will switch to a color set which is built into Xcode
    
    init(hex: UInt){
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

enum Theme{
    // Surfaces
    
    static let surfaceApp = Color(hex: 0x14121C) // window background
    static let surfaceCard = Color(hex: 0x1B1926) // panels and cards
    static let surfaceSunken = Color(hex: 0x221E30) // wells, chips, rail
    
    //Borders
    static let borderSoft = Color(hex: 0x2B2640)
    static let borderStrong = Color(hex: 0x4A4266)
    
    //Text
    static let textStrong = Color(hex: 0xF4F1FF)
    static let textBody = Color(hex: 0xCDC6EC)
    static let textMuted = Color(hex: 0xA49CC2)
    static let textFaint = Color(hex: 0x7D7699)
    
    //Accent
    static let primary = Color(hex: 0xEE9A6B)
    static let primaryTint = Color(hex: 0x3A2A1E)
    static let tokenInk = Color(hex: 0xF6C3A1)
    static let literal = Color(hex: 0x3A1F0E)
    
    //Status
    static let warning = Color(hex: 0xE6B455)
    static let warningTint = Color(hex: 0x3A2F1A)
    static let danger = Color(hex: 0xEC8175)
}
