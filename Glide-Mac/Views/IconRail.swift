//
//  Untitled.swift
//  Glide-Mac
//
//  Created by Aarnav on 8/10/26.
//

import SwiftUI

struct IconRail: View {
    var body: some View{
        VStack(spacing: 20){
            Image(systemName: "paperplane.fill")
                .foregroundStyle(Theme.primary)
            
            Image(systemName: "sun.max")
                .foregroundStyle(Theme.textFaint)
            
            Image(systemName: "book")
                .foregroundStyle(Theme.textFaint)
            
            Image(systemName: "timer")
                .foregroundStyle(Theme.textFaint)
            
            Image(systemName: "square.stack")
                .foregroundStyle(Theme.textFaint)
            
            Image(systemName: "flame")
                .foregroundStyle(Theme.textFaint)
            
            Spacer()
            
            Image(systemName: "gearshape")
                .foregroundStyle(Theme.textFaint)
        }
        .font(.system(size: 18))
        .padding(.vertical, 20)
        .frame(width: 60)
        .frame(maxHeight: .infinity)
        .background(Theme.surfaceSunken)
    }
}

#Preview {
    IconRail()
}
