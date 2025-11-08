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
                INSERT INTO users (id, email, username, password, created_at)
                VALUES ($1, $2, $3, $4, $5)
                """)
            defer { statement.close() }
            let date = ISO8601DateFormatter().string(from: Date())
            try statement.execute(parameterValues: [idString, email, username, hashedPassword, date])

            // Lưu vào SwiftData
            if let context = modelContext {
                let newUser = UserModel(id: id, email: email, username: username, password: hashedPassword)
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
            let statement = try connection.prepareStatement(text: "SELECT id, username, password FROM users WHERE email = $1")
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
                        let newUser = UserModel(id: userId, email: email, username: username, password: storedPassword)
                        context.insert(newUser)
                        try context.save()
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
        authManager.signOut()
        self.isSignedIn = false
        self.username = nil

        // Xóa SwiftData
        if let context = modelContext {
            do {
                try context.delete(model: UserModel.self)
                try context.save()
            } catch {
                print("Lỗi khi xóa user khỏi SwiftData: \(error)")
            }
        }
    }
}
