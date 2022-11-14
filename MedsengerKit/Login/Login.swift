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
    
    class var isSignedIn: Bool { KeyСhain.apiToken != nil }
    
    enum SignInCompletionCodes {
        case success, unknownError, userIsNotActivated, incorrectData, incorrectPassword
    }
    
    public func signIn(login: String, password: String, completion: @escaping (_ result: SignInCompletionCodes) -> Void) {
        let resource = SignInResource(email: login, password: password)
        request = APIRequest(resource: resource)
        request?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    KeyСhain.apiToken = data.api_token
                    User.saveUserFromJson(data: data)
                    completion(.success)
                } else {
                    completion(.unknownError)
                }
            case .failure(let requestError):
                switch requestError {
                case .api(let apiError):
                    switch apiError[0] {
                    case "User is not activated":
                        completion(.userIsNotActivated)
                    case "Incorrect data":
                        completion(.incorrectData)
                    case "Incorrect password":
                        completion(.incorrectPassword)
                    default:
                        processRequestError(requestError, "sign in")
                        completion(.unknownError)
                    }
                default:
                    processRequestError(requestError, "sign in")
                    completion(.unknownError)
                }
            }
        }
    }
    
    enum ChangePasswordCompletionCodes {
        case success, unknownError, incorrectData
    }
    
    public func changePassword(newPassword: String, completion: @escaping (_ result: ChangePasswordCompletionCodes) -> Void) {
        let changePasswordResource = ChangePasswordResource(newPassword: newPassword)
        changePasswordRequest = APIRequest(resource: changePasswordResource)
        changePasswordRequest?.execute { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(.unknownError)
                    return
                }
                KeyСhain.apiToken = data.api_token
                completion(.success)
            case .failure(let error):
                switch error {
                case .api(let apiErrors):
                    switch apiErrors[0] {
                    case "Incorrect data":
                        completion(.incorrectData)
                    default:
                        completion(.unknownError)
                        processRequestError(error, "change password")
                    }
                default:
                    completion(.unknownError)
                    processRequestError(error, "change password")
                }
            }
        }
    }
    
    public func signOut() {
        KeyСhain.apiToken = nil
        User.delete()
    }
    
    public func deauthIfTokenIsNotExists() {
        if !Login.isSignedIn {
            User.delete()
        }
    }
}
