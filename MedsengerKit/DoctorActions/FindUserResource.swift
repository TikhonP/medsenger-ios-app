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
    
    struct Model: Decodable {
        let found: Bool
        let name: String?
        let birthday: Date?
        let id: Int?
    }
    
    typealias ModelType = Model
    
    internal var methodPath: String = "/findUser"
    
    var options: APIResourceOptions {
        APIResourceOptions(
            parseResponse: true,
            params: [
                URLQueryItem(name: "with_data", value: "true"),
                URLQueryItem(name: "clinic", value: "\(clinicId)"),
                URLQueryItem(name: "email", value: email)
            ],
            dateDecodingStrategy: .formatted(DateFormatter.ddMMyyyy)
        )
    }
    
    struct ContractExistError: Error { }
    
    let apiErrors: [APIResourceError<Error>] = [
        APIResourceError(errorString: "Contract exists", error: ContractExistError())
    ]
}
