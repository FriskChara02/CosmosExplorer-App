//
//  AppleService.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 9/12/25.
//

import Foundation
import SwiftUI
import AuthenticationServices
import CryptoKit

// MARK: - Apple Sign-In Service
class AppleService: NSObject, ObservableObject {
    static let shared = AppleService()
    
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    
    private var currentNonce: String?
    private var completionHandler: ((Result<AppleUser, Error>) -> Void)?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Sign In với Apple
    /// Đăng nhập bằng Apple ID
    /// - Parameter completion: Callback trả về kết quả (AppleUser hoặc Error)
    // MARK: - Sign In với Apple
    func signIn(completion: @escaping (Result<AppleUser, Error>) -> Void) {
        self.completionHandler = completion
        
        // ⚠️ SIMULATOR WORKAROUND
        if AppleSignInHelper.isSimulator {
            let mockUser = AppleSignInHelper.createMockAppleUser()
            
            // Simulate delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isSignedIn = true
                self.errorMessage = nil
                completion(.success(mockUser))
            }
            return
        }
        
        // Normal flow cho thiết bị thật
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Sign Out
    /// Đăng xuất khỏi Apple ID
    func signOut() {
        self.isSignedIn = false
        self.errorMessage = nil
        self.currentNonce = nil
    }
    
    // MARK: - Check Credential State
    /// Kiểm tra trạng thái credential của Apple ID
    /// - Parameters:
    ///   - userID: Apple User ID
    ///   - completion: Callback trả về trạng thái
    func checkCredentialState(for userID: String, completion: @escaping (ASAuthorizationAppleIDProvider.CredentialState) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userID) { credentialState, error in
            if let error = error {
                print("❌ Error checking credential state: \(error)")
                completion(.notFound)
                return
            }
            completion(credentialState)
        }
    }
    
    // MARK: - Helper: Generate Nonce
    /// Tạo random nonce string để bảo mật
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // MARK: - Helper: SHA256
    /// Hash nonce bằng SHA256
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleService: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("✅ Apple Sign-In: Authorization received")
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Lấy thông tin user
            let userID = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            let identityToken = appleIDCredential.identityToken
            
            print("✅ Apple User ID: \(userID)")
            print("✅ Apple Email: \(email ?? "nil")")
            print("✅ Apple Name: \(fullName?.givenName ?? "nil") \(fullName?.familyName ?? "nil")")
            
            // Tạo AppleUser object
            let appleUser = AppleUser(
                id: userID,
                email: email,
                fullName: fullName,
                identityToken: identityToken
            )
            
            self.isSignedIn = true
            self.errorMessage = nil
            
            // ✅ Gọi completion handler trên main thread
            DispatchQueue.main.async {
                self.completionHandler?(.success(appleUser))
            }
        } else {
            print("❌ Apple Sign-In: Invalid credential type")
            let error = NSError(
                domain: "AppleService",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "Invalid credential type"]
            )
            DispatchQueue.main.async {
                self.completionHandler?(.failure(error))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Xử lý lỗi
        let nsError = error as NSError
        
        print("❌ Apple Sign-In Error Code: \(nsError.code)")
        print("❌ Apple Sign-In Error: \(error.localizedDescription)")
        
        // User cancelled
        if nsError.code == 1001 {
            let cancelError = NSError(
                domain: "AppleService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Người dùng đã hủy đăng nhập"]
            )
            self.errorMessage = "Đã hủy đăng nhập"
            DispatchQueue.main.async {
                self.completionHandler?(.failure(cancelError))
            }
            return
        }
        
        self.errorMessage = error.localizedDescription
        DispatchQueue.main.async {
            self.completionHandler?(.failure(error))
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Lấy window hiện tại
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

// MARK: - Apple User Model
/// Model chứa thông tin user từ Apple
struct AppleUser {
    let id: String
    let email: String?
    let fullName: PersonNameComponents?
    let identityToken: Data?
    
    /// Username được tạo từ email hoặc fullName
    var username: String {
        if let email = email {
            return email.components(separatedBy: "@").first ?? "AppleUser"
        }
        
        if let fullName = fullName {
            let firstName = fullName.givenName ?? ""
            let lastName = fullName.familyName ?? ""
            return "\(firstName)\(lastName)".isEmpty ? "AppleUser" : "\(firstName)\(lastName)"
        }
        
        return "AppleUser_\(id.prefix(8))"
    }
    
    /// Full name formatted
    var displayName: String? {
        guard let fullName = fullName else { return nil }
        let formatter = PersonNameComponentsFormatter()
        return formatter.string(from: fullName)
    }
}
