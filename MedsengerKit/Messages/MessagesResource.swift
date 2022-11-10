//
//  MessagesResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct MessagesResource: APIResource {
    let contractId: Int
    
    typealias ModelType = Array<Message.JsonDeserializer>
    
    var methodPath: String {
        "/doctors/\(contractId)/messages"
    }
    var options = APIResourceOptions(
        dateDecodingStrategy: .secondsSince1970,
        parseResponse: true
    )
}
