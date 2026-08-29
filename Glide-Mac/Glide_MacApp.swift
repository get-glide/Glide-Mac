//
//  Glide_MacApp.swift
//  Glide-Mac
//
//  Created by Aarnav on 6/24/26.
//

import SwiftUI
import SwiftData

@main
struct Glide_MacApp: App {
    init(){
        FontLoader.registerFonts()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
    }
}
