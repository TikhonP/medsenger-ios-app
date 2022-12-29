//
//  SignInResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

struct LoginData {
    let email: String
    let password: String
    
    let uuid = UIDevice.current.identifierForVendor?.uuidString
    let manufacturer = "Apple"
    let platform = UIDevice.current.systemVersion
    let model = UIDevice.current.model
    
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "uuid", value: uuid),
            URLQueryItem(name: "manufacturer", value: manufacturer),
            URLQueryItem(name: "platform", value: platform),
            URLQueryItem(name: "model", value: model),
        ]
    }
}

struct SignInResource: APIResource {
    let email: String
    let password: String

    typealias ModelType = User.JsonDecoder

    var methodPath = "/auth"
    
    var options: APIResourceOptions {
        APIResourceOptions(
            parseResponse: true,
            params: LoginData(email: email, password: password).queryItems,
            headers: [
                "Cache-Control": "no-store; no-cache; must-revalidate"
            ],
            dateDecodingStrategy: .secondsSince1970,
            addApiKey: false
        )
    }
    
    enum SignInError: Error {
        case userIsNotActivated, incorrectData, incorrectPassword
    }
    
    internal var apiErrors: [APIResourceError<Error>] = [
        APIResourceError(errorString: "User is not activated", error: SignInError.userIsNotActivated),
        APIResourceError(errorString: Constants.MedsengerErrorStrings.incorrectData, error: SignInError.incorrectData),
        APIResourceError(errorString: "Incorrect password", error: SignInError.incorrectPassword)
    ]
}


