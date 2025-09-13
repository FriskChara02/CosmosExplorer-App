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

class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var username: String?
    private var modelContext: ModelContext?

    init() {
        // Kiểm tra user đã đăng nhập từ SwiftData
        if let context = modelContext {
            do {
                if let user = try context.fetch(FetchDescriptor<UserModel>()).first {
                    self.isSignedIn = true
                    self.username = user.username
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
                self.username = try row.columns[0].string()
            }
        } catch {
            print("Lỗi khi lấy username: \(error)")
        }
    }

    func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func signUp(email: String, username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Không thể kết nối database"])))
            return
        }
        defer { connection.close() }

        do {
            let id = UUID().uuidString
            let hashedPassword = hashPassword(password)
            let statement = try connection.prepareStatement(text: """
                INSERT INTO users (id, email, username, password, created_at)
                VALUES ($1, $2, $3, $4, $5)
                """)
            defer { statement.close() }
            let date = ISO8601DateFormatter().string(from: Date())
            try statement.execute(parameterValues: [id, email, username, hashedPassword, date])

            if let context = modelContext {
                let newUser = UserModel(id: UUID(uuidString: id)!, email: email, username: username, password: hashedPassword)
                context.insert(newUser)
                try context.save()
            }

            self.isSignedIn = true
            self.username = username
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

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
               let id = try? row.columns[0].string(),
               let username = try? row.columns[1].string(),
               let storedPassword = try? row.columns[2].string() {
                let hashedPassword = hashPassword(password)
                if hashedPassword == storedPassword {
                    self.isSignedIn = true
                    self.username = username
                    if let context = modelContext {
                        let newUser = UserModel(id: UUID(uuidString: id)!, email: email, username: username, password: storedPassword)
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

    func signOut() {
        self.isSignedIn = false
        self.username = nil
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
