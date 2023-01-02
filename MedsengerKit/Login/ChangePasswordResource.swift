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
    
    init(newPassword: String) {
        self.newPassword = newPassword
    }
    
    struct ResponseModel: Decodable {
        let apiToken: String
    }
    
    typealias ModelType = ResponseModel
    
    var params: [String: String] {
        ["password": newPassword,
         "password_confirmation": newPassword]
    }
    
    var methodPath = "/password"
    
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
    
    internal let apiErrors: [APIResourceError<Error>] = []
}
