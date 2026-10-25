//
//  GlideTile.swift
//  Glide-Mac
//
//  Created by Aarnav on 10/23/26.
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