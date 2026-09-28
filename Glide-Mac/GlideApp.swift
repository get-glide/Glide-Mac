//
//  GlideApp.swift
//  Glide-Mac
//
//  Created by Aarnav on 6/24/26.
//

import SwiftUI
import GlideCore

@main
struct GlideApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 940, minHeight: 620)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .defaultSize(width: 1280, height: 820)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var rolloverManager: RolloverManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let store = try! NoteStore.makeDefault()
        rolloverManager = RolloverManager(store: store, noteName: DefaultNote.today.rawValue)
        rolloverManager?.setup()
    }
}
