//
//  DoctorsResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct ContractsRequestAsPatientResource: APIResource {
    typealias ModelType = Array<Contract.JsonDecoderRequestAsPatient>
    
    var methodPath = "/doctors"
    
    var options = APIResourceOptions(
        parseResponse: true,
        params: [
            URLQueryItem(name: "with_inactive", value: "true"),
            URLQueryItem(name: "separate_clinics", value: "true")
        ]
    )
    
    internal let apiErrors: [APIResourceError<Error>] = []
}
