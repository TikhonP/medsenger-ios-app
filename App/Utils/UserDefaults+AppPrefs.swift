//
//  UserDefaults+AppPrefs.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

/// User login role
enum UserRole: String, Codable, CaseIterable {
    case patient, doctor, unknown
    
    var clientsForNetworkRequest: String {
        switch self {
        case .patient:
            return "doctors"
        case .doctor:
            return "patients"
        default:
            return self.rawValue
        }
    }
}

/// Extention for quick accsess to UserDefault information
extension UserDefaults {
    enum Keys {
        static let userRoleKey = "userRole"
        static let fcmTokenKey = "fcmToken"
        static let isPushNotificationsOnKey = "isPushNotificationsOn"
    }
    
    class var userRole: UserRole {
        get {
            guard let stringValue = UserDefaults.standard.string(forKey: Keys.userRoleKey) else {
                return .unknown
            }
            return UserRole(rawValue: stringValue) ?? .unknown
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.userRoleKey)
        }
    }
    
    class var fcmToken: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.fcmTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.fcmTokenKey)
        }
    }
    
    class var isPushNotificationsOn: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.isPushNotificationsOnKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isPushNotificationsOnKey)
        }
    }

    class func registerDefaultValues() {
        UserDefaults.standard.register(defaults: [
            Keys.userRoleKey: UserRole.unknown.rawValue,
            Keys.isPushNotificationsOnKey: false
        ])
    }
}
