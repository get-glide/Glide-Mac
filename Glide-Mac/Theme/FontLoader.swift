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
        let names = [
            "BricolageGrotesque_24pt_SemiCondensed-ExtraBold",
            "HankenGrotesk-Regular",
            "HankenGrotesk-Medium",
            "JetBrainsMono-Regular"
        ]
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("MISSING:", name)
                continue
            }
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                print("REGISTERED:", name)
            } else {
                print("FAILED:", name, error.debugDescription)
            }
        }
    }
}
