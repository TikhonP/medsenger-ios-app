//
//  Account.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

enum SignInCompletionCodes {
    case success
    case unknownError
    case userIsNotActivated
    case incorrectData
    case incorrectPassword
}

class Account {
    
    private var request: APIRequest<SignInResource>?
    
    public var isSignedIn: Bool {
        KeychainSwift.apiToken != nil
    }
    
    public init() {}
    
    public func signIn(login: String, password: String, completion: @escaping (_ code: SignInCompletionCodes) -> Void) {
        let resource = SignInResource(email: login, password: password)
        request = APIRequest(resource: resource)
        request?.execute { data, errorReponse, networkRequestError in
            if let errorReponse = errorReponse {
                switch errorReponse.error[0] {
                case "User is not activated":
                    completion(.userIsNotActivated)
                case "Incorrect data":
                    completion(.incorrectData)
                case "Incorrect password":
                    completion(.incorrectPassword)
                default:
                    print("Unknown Error: \(errorReponse.error)")
                    completion(.unknownError)
                }
                return
            }
            
            if let data = data {
                KeychainSwift.apiToken = data.data.api_token
                data.data.saveUser()
                completion(.success)
                return
            }
            
            print("Error: \(String(describing: errorReponse)), \(String(describing: networkRequestError))")
            completion(.unknownError)
        }
    }
}
