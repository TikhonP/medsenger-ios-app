//
//  UserDefaults+AppPrefs.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

/// Extention for quick accsess to UserDefault information
//extension UserDefaults {
//    private enum Keys {
//        static let signedIn = "lastMedsengerUploadedDate"
//    }
//    
//    class var savedGemocardUUID: String? {
//        get {
//            return UserDefaults.standard.string(forKey: Keys.savedGemocardUUIDkey)
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: Keys.savedGemocardUUIDkey)
//        }
//    }
//    
//    class func registerDefaultValues() {
//        UserDefaults.standard.register(defaults: [
//            Keys.saveUUIDkey: KeychainSwift.apiToken == nil,
//        ])
//    }
//}
