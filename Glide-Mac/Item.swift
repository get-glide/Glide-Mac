//
//  Item.swift
//  Glide-Mac
//
//  Created by Aarnav on 6/24/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
