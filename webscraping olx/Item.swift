//
//  Item.swift
//  webscraping olx
//
//  Created by Felipe C. Araujo on 10/02/25.
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
