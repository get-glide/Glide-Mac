//
//  DaySidebar.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/7/26.
//

import SwiftUI
import GlideCore

struct DaySidebar: View {
    let tasks: [RailTask]
    let untimedCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Today")
                    .font(Theme.ui(14))
                    .foregroundStyle(Theme.label)
                
                Text(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.labelTertiary)
                
                Spacer()
            }
            .frame(height: Theme.barHeight)
            
            TodayRail(tasks: tasks)
            
            GlideTile(padding: 12) {
                HStack {
                    Text("No time set")
                        .font(Theme.ui(12.5))
                        .foregroundStyle(Theme.label)
                    Spacer()
                    Text("\(untimedCount)")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.labelSecondary)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceApp)
    }
}
