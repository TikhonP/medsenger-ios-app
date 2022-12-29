//
//  DeactivateMessagesResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 11.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct DeactivateMessagesResource: APIResource {
    let contractId: Int
    
    typealias ModelType = EmptyModel
    
    var methodPath: String {
        "/contracts/\(contractId)/decline"
    }
    
    var options = APIResourceOptions(
        method: .POST
    )
    
    internal var apiErrors: [APIResourceError<Error>] = []
}
