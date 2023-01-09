//
//  RemoveScenarioResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct RemoveScenarioResource: APIResource {
    let contractId: Int
    
    typealias ModelType = EmptyModel
    
    var methodPath: String { "/contracts/\(contractId)/remove_scenario" }
    
    internal var options = APIResourceOptions(method: .POST)
    
    let apiErrors: [APIResourceError<Error>] = []
}
