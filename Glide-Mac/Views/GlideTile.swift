//
//  GlideTile.swift
//  Glide-Mac
//
//  Created by Aarnav on 9/7/26.
//

import SwiftUI

struct GlideTile<Content: View>: View {
    var padding: CGFloat = Theme.tilePadding
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surfaceTile)
            .clipShape(RoundedRectangle(cornerRadius: Theme.tileRadius, style: .continuous))
    }
}

struct GlideBlockTile<Content: View>: View {
    let height: CGFloat
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, height < 30 ? 4 : 10)
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .topLeading)
            .clipped()
            .background(Theme.surfaceTile)
            .clipShape(RoundedRectangle(cornerRadius: height < 20 ? 6 : Theme.tileRadius, style: .continuous))
    }
}
