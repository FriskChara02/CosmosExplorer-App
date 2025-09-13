//
//  UserModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import SwiftData

@Model
class UserModel: Identifiable {
    var id: UUID
    var email: String
    var username: String?
    var password: String
    var createdAt: Date

    init(id: UUID = UUID(), email: String, username: String? = nil, password: String, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.username = username
        self.password = password
        self.createdAt = createdAt
    }
}

