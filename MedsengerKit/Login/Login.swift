//
//  Login.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class Login {
    static var isSignedIn: Bool { KeyChain.apiToken != nil }
    
    /// Sign in into Medsenger account and get api key
    /// - Parameters:
    ///   - login: User login
    ///   - password: User password
    public static func signIn(login: String, password: String) async throws {
        let resource = SignInResource(email: login, password: password)
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
    
    /// Sign out from account
    public static func signOut() async throws {
        _ = await (PushNotifications.signOutFcmToken(), try User.delete())
        KeyChain.apiToken = nil
        UserDefaults.userRole = .unknown
    }
    
    public static func deauthIfTokenIsNotExists() async {
        if !isSignedIn {
            try? await signOut()
        }
    }
}
