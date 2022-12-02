//
//  ConcludeContractResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 11.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct ConcludeContractResource: APIResource {
    let contractId: Int
    
    typealias ModelType = EmptyModel
    
    var methodPath: String {
        "/contracts/\(contractId)/conclusion"
    }
    
    var options = APIResourceOptions(
        method: .POST
    )
}
