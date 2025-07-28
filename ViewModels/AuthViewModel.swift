//
//  AuthViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftData

class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var username: String?
    private let db = Firestore.firestore()
    private var modelContext: ModelContext?

    init() {
        if let user = Auth.auth().currentUser {
            isSignedIn = true
            fetchUsername(userId: user.uid)
        }
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func fetchUsername(userId: String) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let username = data["username"] as? String {
                self.username = username
            }
        }
    }

    func signUp(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if password.count < 6 {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mật khẩu phải có ít nhất 6 ký tự"])))
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Không thể tạo người dùng"])))
                return
            }

            let userData: [String: Any] = [
                "id": user.uid,
                "email": email,
                "username": username,
                "createdAt": Timestamp()
            ]

            self.db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let context = self.modelContext {
                    let newUser = UserModel(id: user.uid, email: email, username: username)
                    context.insert(newUser)
                }

                self.isSignedIn = true
                self.username = username
                completion(.success(()))
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let user = result?.user {
                self.fetchUsername(userId: user.uid)
            }

            self.isSignedIn = true
            completion(.success(()))
        }
    }

    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isSignedIn = false
            self.username = nil
        } catch {
            print("Lỗi khi đăng xuất: \(error)")
        }
    }
}
