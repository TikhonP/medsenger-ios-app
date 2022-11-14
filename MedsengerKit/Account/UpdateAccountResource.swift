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
    
    var birthdayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"
        return dateFormatter.string(from: birthday)
    }
    
    
    var params: [String: String] {
        ["name": name,
         "email": email,
         "phone": phone,
         "birthday": birthdayString]
    }
    
    var methodPath = "/account"
    
    var options: APIResourceOptions {
        let result = multipartFormData(params: params)
        return APIResourceOptions(
            httpBody: result.httpBody,
            httpMethod: .POST,
            headers: result.headers
        )
    }
}

