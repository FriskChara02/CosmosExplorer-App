//
//  Item.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 27/7/25.
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
