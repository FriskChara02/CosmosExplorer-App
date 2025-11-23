//
//  AuthViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import SwiftData
import PostgresClientKit
import CryptoKit

// MARK: - AuthManager
final class AuthManager {
    static let shared = AuthManager()
    
    @Published var currentUserId: UUID?
    @Published var isSignedIn = false
    @Published var username: String?
    
    private let userIdKey = "currentUserId"
    
    private init() {
        loadSavedUser()
    }
    
    private func loadSavedUser() {
        if let savedId = UserDefaults.standard.string(forKey: userIdKey),
           let uuid = UUID(uuidString: savedId) {
            self.currentUserId = uuid
            self.isSignedIn = true
        }
    }
    
    func signIn(userId: UUID, username: String? = nil) {
        self.currentUserId = userId
        self.username = username
        self.isSignedIn = true
        UserDefaults.standard.set(userId.uuidString, forKey: userIdKey)
    }
    
    func signOut() {
        self.currentUserId = nil
        self.username = nil
        self.isSignedIn = false
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}

// MARK: - AuthViewModel (Quản lý đăng nhập, đăng ký, v.v.)
class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var username: String?
    @Published var currentUser: UserModel? = nil
    public var modelContext: ModelContext?
    
    private let authManager = AuthManager.shared
    
    init() {
        self.isSignedIn = authManager.isSignedIn
        self.username = authManager.username
        
        if let context = modelContext {
            do {
                if let user = try context.fetch(FetchDescriptor<UserModel>()).first {
                    if authManager.currentUserId == nil {
                        authManager.signIn(userId: user.id, username: user.username)
                        self.isSignedIn = true
                        self.username = user.username
                    }
                }
            } catch {
                print("Lỗi khi kiểm tra user trong SwiftData: \(error)")
            }
        }
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func fetchUsername(userId: String) {
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }

        do {
            let statement = try connection.prepareStatement(text: "SELECT username FROM users WHERE id = $1")
            defer { statement.close() }
            let cursor = try statement.execute(parameterValues: [userId])
            defer { cursor.close() }
            
            if let row = try cursor.next()?.get() {
                let fetchedUsername = try row.columns[0].string()
                self.username = fetchedUsername
                authManager.username = fetchedUsername
            }
        } catch {
            print("Lỗi khi lấy username: \(error)")
        }
    }

    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Sign Up
    func signUp(email: String, username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Không thể kết nối database"])))
            return
        }
        defer { connection.close() }

        do {
            let id = UUID()
            let idString = id.uuidString
            let hashedPassword = hashPassword(password)
            let statement = try connection.prepareStatement(text: """
                INSERT INTO users (id, email, username, password, created_at, rank, score, status, role)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                """)
            defer { statement.close() }
            let date = ISO8601DateFormatter().string(from: Date())
            try statement.execute(parameterValues: [
                idString,
                email,
                username,
                hashedPassword,
                date,
                2000, // default rank
                0, // default score
                "online", // default status
                "user" // default role
            ])

            // Lưu vào SwiftData
            if let context = modelContext {
                let newUser = UserModel(
                    id: id,
                    email: email,
                    username: username,
                    password: hashedPassword,
                    rank: 2000,
                    score: 0,
                    status: "online",
                    role: "user"
                )
                context.insert(newUser)
                try context.save()
            }

            // Cập nhật AuthManager
            authManager.signIn(userId: id, username: username)
            self.isSignedIn = true
            self.username = username
            
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Không thể kết nối database"])))
            return
        }
        defer { connection.close() }

        do {
            let statement = try connection.prepareStatement(text: """
                SELECT id, username, password, avatar, user_description, date_of_birth, location, 
                       gender, hobbies, bio, rank, score, token, status, role, created_at 
                FROM users WHERE email = $1
            """)
            defer { statement.close() }
            let cursor = try statement.execute(parameterValues: [email])
            defer { cursor.close() }
            
            if let row = try cursor.next()?.get(),
               let idString = try? row.columns[0].string(),
               let userId = UUID(uuidString: idString),
               let username = try? row.columns[1].string(),
               let storedPassword = try? row.columns[2].string() {
                
                let hashedPassword = hashPassword(password)
                if hashedPassword == storedPassword {
                    // Cập nhật AuthManager
                    authManager.signIn(userId: userId, username: username)
                    self.isSignedIn = true
                    self.username = username

                    // Lưu vào SwiftData
                    if let context = modelContext {
                        let avatar = try? row.columns[3].string()
                        let userDescription = try? row.columns[4].string()
                        let dateOfBirthString = try? row.columns[5].string()
                        let location = try? row.columns[6].string()
                        let gender = try? row.columns[7].string()
                        let hobbies = try? row.columns[8].string()
                        let bio = try? row.columns[9].string()
                        let rank = (try? row.columns[10].int()) ?? 2000
                        let score = (try? row.columns[11].int()) ?? 0
                        let token = try? row.columns[12].string()
                        let status = try? row.columns[13].string()
                        let role = try? row.columns[14].string()
                        let createdAtString = try? row.columns[15].string()
                        
                        var dateOfBirth: Date?
                        if let dateString = dateOfBirthString {
                            dateOfBirth = ISO8601DateFormatter().date(from: dateString)
                        }
                        
                        var createdAt = Date()
                        if let createdString = createdAtString {
                            createdAt = ISO8601DateFormatter().date(from: createdString) ?? Date()
                        }
                        
                        let newUser = UserModel(
                            id: userId,
                            email: email,
                            username: username,
                            password: storedPassword,
                            createdAt: createdAt,
                            avatar: avatar,
                            userDescription: userDescription,
                            dateOfBirth: dateOfBirth,
                            location: location,
                            gender: gender,
                            hobbies: hobbies,
                            bio: bio,
                            rank: rank,
                            score: score,
                            token: token,
                            status: status,
                            role: role
                        )
                        context.insert(newUser)
                        try context.save()
                        self.currentUser = newUser
                    }
                    
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mật khẩu không đúng nhaaaaa"])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email không tồn tại nhennnn"])))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Không thể kết nối database"])))
            return
        }
        defer { connection.close() }
        
        do {
            let newPassword = UUID().uuidString.prefix(8)
            let hashedPassword = hashPassword(String(newPassword))
            let statement = try connection.prepareStatement(text: "UPDATE users SET password = $1 WHERE email = $2")
            defer { statement.close() }
            try statement.execute(parameterValues: [hashedPassword, email])
            
            print("Mật khẩu mới cho \(email): \(newPassword)")
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        if let context = modelContext,
           let user = try? context.fetch(FetchDescriptor<UserModel>()).first {
            user.status = "offline"
            try? context.save()
            
            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: "UPDATE users SET status = $1 WHERE id = $2")
                defer { statement.close() }
                try statement.execute(parameterValues: ["offline", user.id.uuidString])
            } catch {
                print("❌ Error updating status in PostgreSQL: \(error)")
            }
        }
        
        authManager.signOut()
        self.isSignedIn = false
        self.username = nil
    }
}

extension AuthViewModel {
    func loadCurrentUserIfNeeded(completion: @escaping (UserModel?) -> Void) {
        guard let context = modelContext else {
            completion(nil)
            return
        }
        
        do {
            let users = try context.fetch(FetchDescriptor<UserModel>())
            if let localUser = users.first {
                print("User loaded from SwiftData: \(localUser.username ?? localUser.email)")
                completion(localUser)
                self.currentUser = localUser
                return
            }
        } catch {
            print("Error fetching from SwiftData: \(error)")
        }
        
        guard let userId = AuthManager.shared.currentUserId else {
            print("No saved userId → not signed in")
            completion(nil)
            return
        }
        
        fetchUserFromServer(id: userId.uuidString) { serverUser in
            guard let serverUser = serverUser else {
                completion(nil)
                return
            }
            
            self.username = serverUser.username
            AuthManager.shared.username = serverUser.username
            
            context.insert(serverUser)
            do {
                try context.save()
                print("User pulled from server & saved to SwiftData")
                completion(serverUser)
                self.currentUser = serverUser
            } catch {
                print("Failed to save pulled user to SwiftData: \(error)")
                completion(serverUser)
                self.currentUser = serverUser
            }
        }
    }
    
    public func fetchUserFromServer(id: String, completion: @escaping (UserModel?) -> Void) {
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("Cannot connect to PostgreSQL")
            completion(nil)
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT email, username, password, created_at, avatar, user_description, 
                       date_of_birth, location, gender, hobbies, bio, rank, score, 
                       token, status, role
                FROM users WHERE id = $1
                """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [id])
            defer { cursor.close() }
            
            guard let row = try cursor.next()?.get() else {
                print("No user found on server with id: \(id)")
                completion(nil)
                return
            }
            
            let email = try row.columns[0].string()
            let username = try row.columns[1].optionalString()
            let password = try row.columns[2].string()
            let createdAtStr = try row.columns[3].string()
            let avatar = try row.columns[4].optionalString()
            let userDescription = try row.columns[5].optionalString()
            let dobStr = try row.columns[6].optionalString()
            let location = try row.columns[7].optionalString()
            let gender = try row.columns[8].optionalString()
            let hobbies = try row.columns[9].optionalString()
            let bio = try row.columns[10].optionalString()
            let rank = (try? row.columns[11].int()) ?? 2000
            let score = (try? row.columns[12].int()) ?? 0
            let token = try row.columns[13].optionalString()
            let status = try row.columns[14].optionalString() ?? "offline"
            let role = try row.columns[15].optionalString() ?? "user"
            
            let createdAt = ISO8601DateFormatter().date(from: createdAtStr) ?? Date()
            let dateOfBirth: Date? = dobStr.flatMap { ISO8601DateFormatter().date(from: $0) }
            
            let user = UserModel(
                id: UUID(uuidString: id)!,
                email: email,
                username: username,
                password: password,
                createdAt: createdAt,
                avatar: avatar,
                userDescription: userDescription,
                dateOfBirth: dateOfBirth,
                location: location,
                gender: gender,
                hobbies: hobbies,
                bio: bio,
                rank: rank,
                score: score,
                token: token,
                status: status,
                role: role
            )
            
            completion(user)
            
        } catch {
            print("Error fetching user from server: \(error)")
            completion(nil)
        }
    }
}
