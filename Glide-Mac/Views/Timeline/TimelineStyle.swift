//
//  TimelineStyle.swift
//  Glide-Mac
//
//  Created by Pranay Venkat Aluri on 10/25/26.
//

import SwiftUI

struct TimelineStyle {
    var background: Color
    var card: Color
    var line: Color
    var accent: Color
    var amber: Color
    var now: Color
    var onAmber: Color
    var primaryText: Color
    var secondaryText: Color

    static var main: TimelineStyle {
        TimelineStyle(
            background: Theme.chrome, card: Theme.card, line: Theme.accent.opacity(0.6),
            accent: Theme.accent, amber: Theme.amber, now: Theme.now,
            onAmber: Theme.surfaceApp, primaryText: Theme.label, secondaryText: Theme.chromeText
        )
    }

    static var mini: TimelineStyle {
        TimelineStyle(
            background: MiniStyle.page, card: MiniStyle.card, line: MiniStyle.accent.opacity(0.5),
            accent: MiniStyle.accent, amber: MiniStyle.amber, now: MiniStyle.now,
            onAmber: MiniStyle.page, primaryText: MiniStyle.text, secondaryText: MiniStyle.textSoft
        )
    }
}

private struct TimelineStyleKey: EnvironmentKey {
    static var defaultValue: TimelineStyle { .main }
}

extension EnvironmentValues {
    var timelineStyle: TimelineStyle {
        get { self[TimelineStyleKey.self] }
        set { self[TimelineStyleKey.self] = newValue }
    }
}
