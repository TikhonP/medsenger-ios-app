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
    
    typealias ModelType = EmptyModel
    
    var methodPath = "/\(UserDefaults.userRole.rawValue)/record"
    
    var httpBody: Data? {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            let data = try encoder.encode(RequestModel(values: values))
            return data
        } catch {
            Logger.urlRequest.error("Failed to encode HealthRecordsResource data: \(error.localizedDescription)")
            return nil
        }
    }
    
    var options: APIResourceOptions {
        APIResourceOptions(
            httpBody: httpBody,
            httpMethod: .POST
        )
    }
}
