//
//  ActionUserResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 23.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct ActionUsedResource: APIResource {
    let messageId: Int
    
    typealias ModelType = EmptyModel
    
    var methodPath: String { "/used/\(messageId)" }
    
    internal var options = APIResourceOptions(method: .POST)
    
    let apiErrors: [APIResourceError<Error>] = []
}
