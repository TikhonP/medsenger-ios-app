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
    var fromMessageId: Int? = nil
    
    init(contractId: Int) {
        self.contractId = contractId
    }
    
    init(contractId: Int, fromMessageId: Int) {
        self.contractId = contractId
        self.fromMessageId = fromMessageId
    }
    
    typealias ModelType = Array<Message.JsonDeserializer>
    
    var methodPath: String {
        if let fromMessageId = fromMessageId {
            return "/doctors/\(contractId)/messages/\(fromMessageId)"
        } else {
            return "/doctors/\(contractId)/messages"
        }
    }
    
    var options = APIResourceOptions(
        dateDecodingStrategy: .secondsSince1970,
        parseResponse: true
    )
}
