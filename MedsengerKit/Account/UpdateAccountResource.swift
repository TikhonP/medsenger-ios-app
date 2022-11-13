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
        dateFormatter.dateFormat = "dd.MM.YY"
        return dateFormatter.string(from: birthday)
    }
    
    var httpBody: Data? {
        let params = [
            "name": name,
            "email": email,
            "phone": phone,
            "birthday": birthdayString
        ] as [String: String] 
        return UpdateAccountResource.requestBodyData(params: params)
    }

    var methodPath = "/account"
    
    var options: APIResourceOptions {
        APIResourceOptions(
            httpBody: httpBody,
            httpMethod: .POST
        )
    }
}

