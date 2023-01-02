//
//  DoctorsArchiveResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct ContractsArchiveRequestAsPatientResource: APIResource {
    typealias ModelType = Array<Contract.JsonDecoderRequestAsPatient>
    
    var methodPath = "/archive/doctors"
    
    var options = APIResourceOptions(
        parseResponse: true,
        params: [
            URLQueryItem(name: "separate_clinics", value: "true")
        ]
    )
    
    internal let apiErrors: [APIResourceError<Error>] = []
}
