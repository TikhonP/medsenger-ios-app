//
//  HealthRecordsResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 01.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

/// Submit `HealthKit` records to medsenger server
struct HealthRecordsResource: APIResource {
    let values: Array<HealthKitRecord>
    
    struct RequestModel: Encodable {
        let values: Array<HealthKitRecord>
    }
    
    struct ResponseModel: Decodable {
        let lastHealthSync: Date
    }
    
    typealias ModelType = ResponseModel
    
    var methodPath = "/\(UserDefaults.userRole.rawValue)/record"
    
    var options: APIResourceOptions {
        APIResourceOptions(
            parseResponse: true,
            method: .POST,
            httpBody: encodeToJSON(
                RequestModel(values: values), keyEncodingStrategy: .convertToSnakeCase),
            dateDecodingStrategy: .secondsSince1970,
            keyDecodingStrategy: .convertFromSnakeCase
        )
    }
    
    internal let apiErrors: [APIResourceError<Error>] = []
}
