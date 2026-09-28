//
//  RolloverManager.swift
//  Glide-Mac
//
//  Created by Pranay Venkat Aluri on 8/14/26.
//

import Foundation
import AppKit
import GlideCore

class RolloverManager {
    private let store: NoteStore
    private let noteName: String
    
    init(store: NoteStore, noteName: String) {
        self.store = store
        self.noteName = noteName
    }
    
    func setup() {
        if shouldRunRollover() {
            performRollover()
        }
        
        scheduleMidnightRollover()
        
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if self?.shouldRunRollover() == true {
                self?.performRollover()
                self?.scheduleMidnightRollover()
            }
        }
    }
    
    private func performRollover() {
        guard let text = try? store.read(noteName) else { return }
        let currentLines = text.components(separatedBy: "\n")
        let updatedLines = applyMidnightRollover(lines: currentLines)
        try? store.write(updatedLines.joined(separator: "\n"), to: noteName)
        UserDefaults.standard.set(Date(), forKey: "lastRolloverDate")
    }
    
    private func shouldRunRollover() -> Bool {
        guard let lastRollover = UserDefaults.standard.object(forKey: "lastRolloverDate") as? Date else {
            return true
        }
        return !Calendar.current.isDateInToday(lastRollover)
    }
    
    private func scheduleMidnightRollover() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let midnight = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else { return }
        
        let timeUntilMidnight = midnight.timeIntervalSince(now)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilMidnight) { [weak self] in
            self?.performRollover()
            self?.scheduleMidnightRollover()
        }
    }
}
