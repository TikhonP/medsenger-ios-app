//
//  DoctorsRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct DoctorsResource: APIResource {
    typealias ModelType = Array<DoctorContract>
    
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = .formatted(DateFormatter.iso8601Full)
    var parseResponse = true
    var httpBody: Data? = nil
    var httpMethod: String = "GET"
    var headers: [String : String]? = nil
    var methodPath = "/doctors"
    var queryItems: [URLQueryItem]? = [
        URLQueryItem(name: "with_inactive", value: "true"),
        URLQueryItem(name: "separate_clinics", value: "true")
    ]
    var addApiKey = true
}
