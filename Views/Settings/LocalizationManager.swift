//
//  LocalizationManager.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/9/25.
//

import Foundation
import Combine

class LanguageManager: ObservableObject {
    @Published var currentLanguage: String = Locale.preferredLanguages[0].prefix(2).description {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            // Gửi thông báo để cập nhật giao diện nếu cần
            objectWillChange.send()
        }
    }
    
    static let current = LanguageManager()
    
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            currentLanguage = savedLanguage
        }
    }
    
    func string(_ key: String) -> String {
        let bundlePath = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")!
        let bundle = Bundle(path: bundlePath)!
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
