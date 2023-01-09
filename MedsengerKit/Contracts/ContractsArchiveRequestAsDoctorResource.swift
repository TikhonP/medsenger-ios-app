//
//  ContractsArchiveRequestAsDoctorResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 25.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct ContractsArchiveRequestAsDoctorResource: APIResource {
    typealias ModelType = Array<Contract.JsonDecoderRequestAsDoctor>
    
    var methodPath = "/archive/patients"
    
    var options = APIResourceOptions(
        parseResponse: true
    )
    
    let apiErrors: [APIResourceError<Error>] = []
}
