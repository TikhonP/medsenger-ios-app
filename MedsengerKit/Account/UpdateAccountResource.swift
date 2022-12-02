//
//  UpdateAccountResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct UpdateAccountResource: APIResource {
    let name: String
    let email: String
    let phone: String
    let birthday: Date
    
    typealias ModelType = User.JsonDecoder
    
    var birthdayAsString: String {
        return DateFormatter.ddMMyyyy.string(from: birthday)
    }
    
    var params: [String: String] {
        ["name": name,
         "email": email,
         "phone": phone,
         "birthday": birthdayAsString]
    }
    
    var methodPath = "/account"
    
    var options: APIResourceOptions {
        let result = multipartFormData(textParams: params)
        return APIResourceOptions(
            parseResponse: false,
            method: .POST,
            httpBody: result.httpBody,
            headers: result.headers
        )
    }
}
