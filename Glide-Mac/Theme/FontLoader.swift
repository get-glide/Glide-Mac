//
//  FontLoader.swift
//  Glide-Mac
//
//  Created by Aarnav on 8/29/26.
//

import SwiftUI
import CoreText

enum FontLoader {
    static func registerFonts() {
        for name in ["Geist-VariableFont_wght", "GeistMono-VariableFont_wght"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("MISSING:", name)
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                print("FAILED:", name, error.debugDescription)
            }
        }
    }
}
