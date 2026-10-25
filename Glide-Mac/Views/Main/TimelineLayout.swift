//
//  TimelineLayout.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/24/26.
//

import SwiftUI
import Observation

@Observable
final class TimelineLayout {
    var width: Double = Theme.timelineDefault
    var visible = true
    
    func clamp(_ value: Double) -> Double {
        min(Theme.timelineMax, max(Theme.timelineMin, value))
    }
}

struct TimelineColumn<Content: View>: View {
    let layout: TimelineLayout
    @ViewBuilder var content: Content
    
    var body: some View {
        content.frame(width: layout.visible ? layout.width : nil, alignment: .leading)
    }
}
