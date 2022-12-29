//
//  PatientsResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 23.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct ContractsRequestAsDoctorResource: APIResource {
    typealias ModelType = Array<Contract.JsonDecoderRequestAsDoctor>
    
    var methodPath = "/patients"
    
    var options = APIResourceOptions(
        parseResponse: true,
        params: [
            URLQueryItem(name: "with_inactive", value: "true"),
        ]
    )
    
    internal var apiErrors: [APIResourceError<Error>] = []
}
