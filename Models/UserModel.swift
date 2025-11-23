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
    var avatar: String?
    var userDescription: String?
    var dateOfBirth: Date?
    var location: String?
    var gender: String?
    var hobbies: String?
    var bio: String?
    var rank: Int
    var score: Int
    var token: String?
    var status: String? // online, offline, idle, dnd, invisible
    var role: String? // user, admin, super_admin

    init(
        id: UUID = UUID(),
        email: String,
        username: String? = nil,
        password: String,
        createdAt: Date = Date(),
        avatar: String? = nil,
        userDescription: String? = nil,
        dateOfBirth: Date? = nil,
        location: String? = nil,
        gender: String? = nil,
        hobbies: String? = nil,
        bio: String? = nil,
        rank: Int = 2000,
        score: Int = 0,
        token: String? = nil,
        status: String? = "online",
        role: String? = "user"
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.password = password
        self.createdAt = createdAt
        self.avatar = avatar
        self.userDescription = userDescription
        self.dateOfBirth = dateOfBirth
        self.location = location
        self.gender = gender
        self.hobbies = hobbies
        self.bio = bio
        self.rank = rank
        self.score = score
        self.token = token
        self.status = status
        self.role = role
    }
    
    func getRankColor() -> String {
        switch rank {
        case 0..<1000:
            return "Đỏ"
        case 1000..<1200:
            return "Vàng"
        case 1200..<1400:
            return "Tím"
        case 1400..<1600:
            return "Xanh Dương"
        case 1600..<1800:
            return "Xanh Lá"
        default:
            return "Trắng"
        }
    }
}
