//
//  Login.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class Login {
    static let shared = Login()
    
    private var request: APIRequest<SignInResource>?
    private var changePasswordRequest: APIRequest<ChangePasswordResource>?
    
    var isSignedIn: Bool { KeyChain.apiToken != nil }
    
    enum SignInCompletionCodes {
        case success, unknownError, userIsNotActivated, incorrectData, incorrectPassword
    }
    
    /// Sign in into Medsenger account and get api key
    /// - Parameters:
    ///   - login: User login
    ///   - password: User password
    ///   - completion: Request completion
    public func signIn(login: String, password: String, completion: @escaping (_ result: SignInCompletionCodes) -> Void) {
        let resource = SignInResource(email: login, password: password)
        request = APIRequest(resource)
        request?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    KeyChain.apiToken = data.api_token
                    User.saveUserFromJson(data)
                    completion(.success)
                } else {
                    completion(.unknownError)
                }
            case .failure(let requestError):
                processRequestError(requestError, "sign in")
                switch requestError {
                case .api(let errorResponse, _):
                    if errorResponse.errors.contains("User is not activated") {
                        completion(.userIsNotActivated)
                    } else if errorResponse.errors.contains("Incorrect data") {
                        completion(.incorrectData)
                    } else if errorResponse.errors.contains("Incorrect password") {
                        completion(.incorrectPassword)
                    } else {
                        completion(.unknownError)
                    }
                default:
                    completion(.unknownError)
                }
            }
        }
    }
    
    enum ChangePasswordCompletionCodes {
        case success, unknownError, incorrectData
    }
    
    /// Change password for account
    /// - Parameters:
    ///   - newPassword: New password
    ///   - completion: Request completion
    public func changePassword(newPassword: String, completion: @escaping APIRequestCompletion) {
        let changePasswordResource = ChangePasswordResource(newPassword: newPassword)
        changePasswordRequest = APIRequest(changePasswordResource)
        changePasswordRequest?.execute { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(false)
                    return
                }
                KeyChain.apiToken = data.apiToken
                completion(true)
            case .failure(let error):
                processRequestError(error, "change password")
                completion(false)
            }
        }
    }
    
    /// Sign out from account
    public func signOut() {
        DispatchQueue.global(qos: .background).async {
            PushNotifications.signOutFcmToken()
            KeyChain.apiToken = nil
            User.delete()
            UserDefaults.userRole = .unknown
        }
    }
    
    public func deauthIfTokenIsNotExists() {
        if !isSignedIn {
            signOut()
        }
    }
}
