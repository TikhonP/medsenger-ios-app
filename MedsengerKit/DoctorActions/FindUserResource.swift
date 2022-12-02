//
//  FindUserResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct FindUserResource: APIResource {
    let clinicId: Int
    let email: String
    
    struct CheckModel: Decodable {
        let state: String // "success"
        let found: Bool
    }
    
    struct FoundModel: Decodable {
        let state: String // "success"
        let found: Bool
        let name: String
        let birthday: Date
        let id: Int
    }
    
    typealias ModelType = FoundModel
    
    internal var methodPath: String = "/findUser"
    
    var options: APIResourceOptions {
        APIResourceOptions()
    }
}
