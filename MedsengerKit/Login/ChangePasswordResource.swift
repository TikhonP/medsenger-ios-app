//
//  ChangePasswordResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct ChangePasswordResource: APIResource {
    let newPassword: String
    
    struct ResponseModel: Decodable, Sendable {
        let apiToken: String
    }
    
    typealias ModelType = ResponseModel
    
    var params: [String: String] {
        ["password": newPassword,
         "password_confirmation": newPassword]
    }
    
    let methodPath = "/password"
    
    var options: APIResourceOptions {
        let result = multipartFormData(textParams: params)
        return APIResourceOptions(
            parseResponse: true,
            method: .POST,
            httpBody: result.httpBody,
            headers: result.headers,
            keyDecodingStrategy: .convertFromSnakeCase
        )
    }
    
    let apiErrors: [APIResourceError<Error>] = []
}
