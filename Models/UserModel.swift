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
    var id: String // UID từ Firebase
    var email: String
    var username: String?
    var createdAt: Date

    init(id: String, email: String, username: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.username = username
        self.createdAt = createdAt
    }
}
