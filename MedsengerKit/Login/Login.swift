//
//  Account.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class Login {
    static let shared = Login()
    
    private var request: APIRequest<SignInResource>?
    
    class var isSignedIn: Bool { KeyСhain.apiToken != nil }
    
    enum SignInCompletionCodes {
        case success
        case unknownError
        case userIsNotActivated
        case incorrectData
        case incorrectPassword
    }
    
    public func signIn(login: String, password: String, completion: @escaping (_ code: SignInCompletionCodes) -> Void) {
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
