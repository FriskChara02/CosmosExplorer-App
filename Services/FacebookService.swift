//
//  FacebookService.swift
//  CosmosExplorer
//
//  Facebook Login Service
//

import Foundation
import SwiftUI
import FacebookLogin
import FacebookCore

// MARK: - Facebook Login Service
class FacebookService: ObservableObject {
    static let shared = FacebookService()
    
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    
    private let loginManager = LoginManager()
    
    private init() {}
    
    // MARK: - Sign In với Facebook
    /// Đăng nhập bằng Facebook Account
    /// - Parameters:
    ///   - viewController: UIViewController hiện tại để present Facebook Login
    ///   - completion: Callback trả về kết quả (FacebookUser hoặc Error)
    func signIn(
        from viewController: UIViewController,
        completion: @escaping (Result<FacebookUser, Error>) -> Void
    ) {
        // Kiểm tra xem đã đăng nhập chưa
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            fetchUserInfo(accessToken: accessToken.tokenString, completion: completion)
            return
        }
        
        // Tạo LoginConfiguration
        let configuration = LoginConfiguration(
            permissions: ["public_profile", "email"],
            tracking: .enabled
        )
        
        // Bắt đầu login flow
        loginManager.logIn(
            viewController: viewController,
            configuration: configuration
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let granted, let declined, let token):
                print("✅ Facebook Login Success")
                print("Granted permissions: \(granted)")
                print("Declined permissions: \(declined)")
                
                // Lấy thông tin user
                if let token = token {
                    self.fetchUserInfo(accessToken: token.tokenString, completion: completion)
                } else {
                    let error = NSError(
                        domain: "FacebookService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Không lấy được access token"]
                    )
                    completion(.failure(error))
                }
                
            case .cancelled:
                let error = NSError(
                    domain: "FacebookService",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Người dùng đã hủy đăng nhập"]
                )
                self.errorMessage = "Đã hủy đăng nhập"
                completion(.failure(error))
                
            case .failed(let error):
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch User Info
    /// Lấy thông tin user từ Facebook Graph API
    private func fetchUserInfo(
        accessToken: String,
        completion: @escaping (Result<FacebookUser, Error>) -> Void
    ) {
        let parameters = ["fields": "id,name,email,picture.type(large)"]
        let graphRequest = GraphRequest(
            graphPath: "me",
            parameters: parameters
        )
        
        graphRequest.start { [weak self] _, result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
                return
            }
            
            guard let result = result as? [String: Any] else {
                let error = NSError(
                    domain: "FacebookService",
                    code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Không parse được user data"]
                )
                completion(.failure(error))
                return
            }
            
            // Parse user info
            let id = result["id"] as? String ?? ""
            let name = result["name"] as? String
            let email = result["email"] as? String
            
            // Parse profile picture
            var profilePictureURL: URL?
            if let picture = result["picture"] as? [String: Any],
               let data = picture["data"] as? [String: Any],
               let urlString = data["url"] as? String {
                profilePictureURL = URL(string: urlString)
            }
            
            // Tạo FacebookUser object
            let facebookUser = FacebookUser(
                id: id,
                name: name,
                email: email,
                profilePictureURL: profilePictureURL,
                accessToken: accessToken
            )
            
            self.isSignedIn = true
            self.errorMessage = nil
            completion(.success(facebookUser))
        }
    }
    
    // MARK: - Sign Out
    /// Đăng xuất khỏi Facebook Account
    func signOut() {
        loginManager.logOut()
        self.isSignedIn = false
        self.errorMessage = nil
    }
    
    // MARK: - Check Login Status
    /// Kiểm tra xem user đã đăng nhập Facebook chưa
    func checkLoginStatus(completion: @escaping (Bool) -> Void) {
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            completion(true)
        } else {
            completion(false)
        }
    }
}

// MARK: - Facebook User Model
/// Model chứa thông tin user từ Facebook
struct FacebookUser {
    let id: String
    let name: String?
    let email: String?
    let profilePictureURL: URL?
    let accessToken: String
    
    /// Username được tạo từ email hoặc name
    var username: String {
        if let email = email {
            return email.components(separatedBy: "@").first ?? "FacebookUser"
        }
        
        if let name = name {
            return name.replacingOccurrences(of: " ", with: "")
        }
        
        return "FacebookUser_\(id.prefix(8))"
    }
}
