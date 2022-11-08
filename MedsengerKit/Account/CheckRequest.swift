//
//  AccountRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct CheckResource: APIResource {
    typealias ModelType = User.JsonDecoder
    
    var methodPath = "/check"
    
    var options = APIResourceOptions(
        dateDecodingStrategy: .secondsSince1970,
        parseResponse: true
    )
}

