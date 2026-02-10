//
//  AppleSignInHelper.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 10/12/25.
//

import Foundation
import AuthenticationServices

class AppleSignInHelper {
    
    /// Kiểm tra xem có đang chạy trên Simulator không
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// Mock Apple User cho testing trên Simulator
    static func createMockAppleUser() -> AppleUser {
        return AppleUser(
            id: UUID().uuidString,
            email: "simulator@privaterelay.appleid.com",
            fullName: {
                var components = PersonNameComponents()
                components.givenName = "Loi"
                components.familyName = "Nguyen"
                return components
            }(),
            identityToken: nil
        )
    }
}
