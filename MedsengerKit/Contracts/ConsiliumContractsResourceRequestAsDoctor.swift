//
//  ConsiliumContractsResourceRequestAsDoctor.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 23.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct ConsiliumContractsResourceRequestAsDoctor: APIResource {
    typealias ModelType = Array<Contract.JsonDecoderRequestAsDoctor>
    
    var methodPath = "/helper/\(UserDefaults.userRole.clientsForNetworkRequest)"
    
    var options = APIResourceOptions(
        parseResponse: true,
        params: [
            URLQueryItem(name: "with_inactive", value: "true"),
        ]
    )
}
