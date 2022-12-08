//
//  AddScenarioResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct AddScenarioResource: APIResource {
    let contractId: Int
    let scenarioId: Int
    let params: [ClinicScenarioParamNode]
    
    typealias ModelType = EmptyModel
    
    var methodPath: String { "/contracts/\(contractId)/scenario" }
    
    var data: [String: AnyEncodable] {
        var data: [String: AnyEncodable] = ["id": AnyEncodable(scenarioId)]
        for param in params {
            switch param.type {
            case .checkbox:
                data[param.code] = AnyEncodable(param.toggleValue)
            case .number:
                data[param.code] = AnyEncodable(Int(param.value))
            case .date:
                data[param.code] = AnyEncodable(param.dateValue)
            case .text, .select:
                data[param.code] = AnyEncodable(param.value)
            case .currentDate, .hidden, .unknown:
                continue
            }
        }
        return data
    }
    
    var httpBody: Data? {
        do {
            return try JSONEncoder().encode(data)
        } catch {
            print("AddScenarioResource JSONEncoder Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    var options: APIResourceOptions {
        let httpBody = httpBody
        if let httpBody = httpBody {
            print(String(decoding: httpBody, as: UTF8.self))
        } else {
            print("Data is nil")
        }
        return APIResourceOptions(
            method: .POST,
            httpBody: httpBody
        )
    }
}
