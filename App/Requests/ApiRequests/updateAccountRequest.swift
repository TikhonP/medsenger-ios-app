//
//  updateAccountRequest.swift
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
    
    typealias ModelType = CheckResponse
    
    var parseResponse = false
    var httpBody: Data? {
        let params = [
            "name": name,
            "email": email,
            "phone": phone,
            "birthday": birthdayString
        ] as [String : Any]
        let postString = UpdateAccountResource.getPostString(params: params)
        return postString.data(using: .utf8)
    }
    var httpMethod: String = "GET"
    var headers: [String : String]? = nil
    var methodPath = "/account"
    var queryItems: [URLQueryItem]? = nil
    var addApiKey = true
    
    var birthdayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY"
        return dateFormatter.string(from: birthday)
    }
}

