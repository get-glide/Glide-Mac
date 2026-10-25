//
//  TrafficLights.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
//

import SwiftUI
import AppKit

struct TrafficLights: NSViewRepresentable {
    var height: CGFloat = 52
    var leading: CGFloat = 18
    var spacing: CGFloat = 20
    
    func makeNSView(context: Context) -> TrafficLightsView {
        TrafficLightsView(height: height, leading: leading, spacing: spacing)
    }
    
    func updateNSView(_ view: TrafficLightsView, context: Context) {
        view.reposition()
    }
}

final class TrafficLightsView: NSView {
    private let height: CGFloat
    private let leading: CGFloat
    private let spacing: CGFloat
    private var observers: [NSObjectProtocol] = []
    
    init(height: CGFloat, leading: CGFloat, spacing: CGFloat) {
        self.height = height
        self.leading = leading
        self.spacing = spacing
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        observers.forEach(NotificationCenter.default.removeObserver)
        observers = []
        guard let window else { return }
        
        let events: [Notification.Name] = [
            NSWindow.didResizeNotification,
            NSWindow.didEndLiveResizeNotification,
            NSWindow.didExitFullScreenNotification,
            NSWindow.didBecomeKeyNotification,
            NSWindow.didResignKeyNotification
        ]
        observers = events.map { name in
            NotificationCenter.default.addObserver(forName: name, object: window, queue: .main) { [weak self] _ in
                self?.reposition()
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.reposition()
        }
    }
    
    func reposition() {
        guard let window,
              !window.styleMask.contains(.fullScreen),
              let close = window.standardWindowButton(.closeButton),
              let container = close.superview?.superview else { return }
        
        var frame = container.frame
        frame.size.height = height
        frame.origin.y = window.frame.height - height
        container.frame = frame
        
        let buttons: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]
        for (index, type) in buttons.enumerated() {
            guard let button = window.standardWindowButton(type) else { continue }
            button.setFrameOrigin(NSPoint(
                x: leading + CGFloat(index) * spacing,
                y: (height - button.frame.height) / 2
            ))
        }
    }
}
