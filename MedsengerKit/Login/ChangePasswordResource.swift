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
    
    struct ResponseModel: Decodable {
        let api_token: String
    }
    
    typealias ModelType = ResponseModel
    
    var params: [String: String] {
        ["password": newPassword,
         "password_confirmation": newPassword]
    }
    
    var methodPath = "/password"
    
    var options: APIResourceOptions {
        let result = multipartFormData(params: params)
        return APIResourceOptions(
            parseResponse: true,
            httpBody: result.httpBody,
            httpMethod: .POST,
            headers: result.headers
        )
    }
}
