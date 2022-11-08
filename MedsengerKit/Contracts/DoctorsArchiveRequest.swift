//
//  DoctorsArchiveRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct DoctorsArchiveResource: APIResource {
    typealias ModelType = Array<Contract.JsonDecoderDoctor>
    
    var methodPath = "/archive/doctors"
    
    var options = APIResourceOptions(
        parseResponse: true,
        queryItems: [
            URLQueryItem(name: "separate_clinics", value: "true")
        ]
    )
}
