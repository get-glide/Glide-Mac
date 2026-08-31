//
//  GlideApp.swift
//  Glide-Mac
//
//  Created by Aarnav on 6/24/26.
//

import SwiftUI

@main
struct GlideApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var rolloverManager: RolloverManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        rolloverManager = RolloverManager()
        rolloverManager?.setup()
    }
}
