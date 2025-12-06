//
//  GoogleService.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 6/12/25.
//

import Foundation
import GoogleSignIn
import SwiftUI

// MARK: - Google Sign-In Service
class GoogleService: ObservableObject {
    static let shared = GoogleService()
    
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Sign In với Google
    func signIn(
        presentingViewController: UIViewController,
        completion: @escaping (Result<GoogleUser, Error>) -> Void
    ) {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            let error = NSError(
                domain: "GoogleService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy GIDClientID trong Info.plist"]
            )
            completion(.failure(error))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController
        ) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
                return
            }
            
            guard let result = signInResult,
                  let profile = result.user.profile else {
                let error = NSError(
                    domain: "GoogleService",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Không lấy được thông tin user"]
                )
                completion(.failure(error))
                return
            }
            
            let googleUser = GoogleUser(
                id: result.user.userID ?? "",
                email: profile.email,
                fullName: profile.name,
                givenName: profile.givenName,
                familyName: profile.familyName,
                profileImageURL: profile.imageURL(withDimension: 200)
            )
            
            self.isSignedIn = true
            self.errorMessage = nil
            completion(.success(googleUser))
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.isSignedIn = false
        self.errorMessage = nil
    }
    
    // MARK: - Check Previous Sign-In
    func restorePreviousSignIn(completion: @escaping (GoogleUser?) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                print("⚠️ Không thể restore previous sign-in: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let user = user,
                  let profile = user.profile else {
                completion(nil)
                return
            }
            
            let googleUser = GoogleUser(
                id: user.userID ?? "",
                email: profile.email,
                fullName: profile.name,
                givenName: profile.givenName,
                familyName: profile.familyName,
                profileImageURL: profile.imageURL(withDimension: 200)
            )
            
            self.isSignedIn = true
            completion(googleUser)
        }
    }
    
    // MARK: - Handle URL
    @discardableResult
    func handleURL(_ url: URL) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - Google User Model
struct GoogleUser {
    let id: String
    let email: String
    let fullName: String
    let givenName: String?
    let familyName: String?
    let profileImageURL: URL?
    
    var username: String {
        return email.components(separatedBy: "@").first ?? email
    }
}

// MARK: - SwiftUI Helper
extension View {
    func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootViewController
    }
}

// MARK: - UIViewControllerRepresentable Helper
struct ViewControllerHolder: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
