//
//  DateHelper.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation

struct DateHelper {
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd .MM .yyyy"
        return formatter.string(from: date)
    }
}
