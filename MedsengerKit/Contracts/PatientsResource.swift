//
//  PatientsResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 23.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct PatientsResource: APIResource {
    typealias ModelType = Array<Contract.JsonDecoderPatient>
    
    var methodPath = "/patients"
    
    var options = APIResourceOptions(
        parseResponse: true,
        queryItems: [
            URLQueryItem(name: "with_inactive", value: "true"),
            URLQueryItem(name: "separate_clinics", value: "true")
        ]
    )
}
