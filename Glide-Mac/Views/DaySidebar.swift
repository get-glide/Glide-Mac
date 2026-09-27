import SwiftUI
import GlideCore

enum SidebarRange: String, CaseIterable {
    case today = "Today"
    case week = "This Week"
    case month = "This Month"
}

struct DaySidebar: View {
    let tasks: [RailTask]
    let untimedCount: Int
    
    @State private var range: SidebarRange = .today
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(range.rawValue)
                    .font(Theme.ui(14))
                    .foregroundStyle(Theme.label)
                
                Text(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.labelTertiary)
                
                Spacer()
            }
            .frame(height: Theme.barHeight)
            
            HStack(spacing: 6) {
                ForEach(SidebarRange.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .font(Theme.ui(11.5))
                        .foregroundStyle(range == option ? Theme.label : Theme.labelSecondary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(range == option ? Theme.surfaceTile : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .pressable { range = option }
                }
            }
            .padding(.bottom, 10)
            
            TodayRail(tasks: tasks)
                .padding(.top, 4)
            
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
            .padding(.top, 12)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.surfaceSidebar)
    }
}
