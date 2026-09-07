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
    var getText: (() -> String)?
    var setText: ((String) -> Void)?
    
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
    
    private func shouldRunRollover() -> Bool {
        guard let lastRollover = UserDefaults.standard.object(forKey: "lastRolloverDate") as? Date else {
            return true
        }
        return !Calendar.current.isDateInToday(lastRollover)
    }
    
    private func performRollover() {
        guard let getText = getText, let setText = setText else { return }
        
        let currentLines = getText().components(separatedBy: "\n")
        let updatedLines = GlideCore.applyMidnightRollover(lines: currentLines)
        setText(updatedLines.joined(separator: "\n"))
        
        UserDefaults.standard.set(Date(), forKey: "lastRolloverDate")
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
