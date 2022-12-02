//
//  MessagesResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

/// Get list of messages resource
struct MessagesResource: APIResource {
    let contractId: Int
    let fromMessageId: Int?
    
    /// Get list of messages for contract
    /// - Parameter contractId: Contract id
    init(for contractId: Int) {
        self.contractId = contractId
        self.fromMessageId = nil
    }
    
    /// Get list of last messages for contract
    /// - Parameters:
    ///   - contractId: Contract id
    ///   - fromMessageId: Message id from start fetch
    init(for contractId: Int, fromMessageId: Int) {
        self.contractId = contractId
        self.fromMessageId = fromMessageId
    }
    
    typealias ModelType = Array<Message.JsonDecoder>
    
    var methodPath: String {
        if let fromMessageId = fromMessageId {
            return "/doctors/\(contractId)/messages/\(fromMessageId)"
        } else {
            return "/doctors/\(contractId)/messages"
        }
    }
    
    var options = APIResourceOptions(
        parseResponse: true,
        dateDecodingStrategy: .secondsSince1970
    )
}
