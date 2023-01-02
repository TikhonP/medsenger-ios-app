//
//  Login.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import UIKit

class Login {
    static var isSignedIn: Bool { KeyChain.apiToken != nil }
    
    /// Sign in into Medsenger account and get api key
    /// - Parameters:
    ///   - login: User login
    ///   - password: User password
    @MainActor public static func signIn(login: String, password: String) async throws {
        let resource = SignInResource(
            email: login,
            password: password,
            uuid: UIDevice.current.identifierForVendor?.uuidString,
            platform: UIDevice.current.systemVersion,
            model: UIDevice.current.model)
        do {
            let data = try await APIRequest(resource).executeWithResult()
            KeyChain.apiToken = data.api_token
            try await User.saveUserFromJson(data)
        } catch {
            throw await processRequestError(error, "sign in", apiErrors: resource.apiErrors)
        }
    }
    
    enum ChangePasswordCompletionCodes {
        case success, unknownError, incorrectData
    }
    
    /// Change password for account
    /// - Parameters:
    ///   - newPassword: New password
    public static func changePassword(newPassword: String) async throws {
        let changePasswordResource = ChangePasswordResource(newPassword: newPassword)
        do {
            let data = try await APIRequest(changePasswordResource).executeWithResult()
            KeyChain.apiToken = data.apiToken
        } catch {
            throw await processRequestError(error, "change password", apiErrors: changePasswordResource.apiErrors)
        }
    }
    
    private static func clearAllFiles() async throws {
        let fileManager = FileManager()
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return
        }
        let fileNames = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [])
        for fileName in fileNames {
            do {
                try fileManager.removeItem(at: fileName)
            } catch {
                print("Failed to delete filename: \(fileName)")
            }
        }
    }
    
    /// Change user role: patient or doctor
    /// - Parameter role: The user role
    public static func changeRole(_ role: UserRole) async {
        _ = await (try? PersistenceController.clearDatabase(withUser: false), PushNotifications.removeOldFcmToken(), try? clearAllFiles())
        UserDefaults.userRole = role
        _ = await (PushNotifications.storeFcmTokenAsNewRole(), try? ChatsViewModel.shared.getContracts(presentFailedAlert: true))
    }
    
    /// Sign out from account
    public static func signOut() async throws {
        _ = await (PushNotifications.signOutFcmToken(), try User.delete(), try? clearAllFiles())
        KeyChain.apiToken = nil
        UserDefaults.userRole = .unknown
    }
    
    public static func deauthIfTokenIsNotExists() async {
        if !isSignedIn {
            try? await signOut()
        }
    }
}
