//
//  ConsiliumContractsResourceRequestAsPatient.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 19.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct ConsiliumContractsResourceRequestAsPatient: APIResource {
    typealias ModelType = Array<Contract.JsonDecoderRequestAsPatient>
    
    var methodPath = "/helper/\(UserDefaults.userRole.clientsForNetworkRequest)"
    
    var options = APIResourceOptions(
        parseResponse: true,
        params: [
            URLQueryItem(name: "with_inactive", value: "true"),
            URLQueryItem(name: "separate_clinics", value: "true")
        ]
    )
}
