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
    
    init(contractId: Int, scenarioId: Int, params: [ClinicScenarioParamNode]) {
        self.contractId = contractId
        self.scenarioId = scenarioId
        self.params = params
    }
    
    typealias ModelType = EmptyModel
    
    internal var methodPath: String { "/contracts/\(contractId)/scenario" }
    
    @MainActor var textParams: [String: String] {
        var data: [String: String] = ["id": String(scenarioId)]
        for param in self.params {
            switch param.type {
            case .checkbox:
                data[param.code] = String(param.toggleValue)
            case .number:
                data[param.code] = param.value
            case .date:
                data[param.code] = DateFormatter.ddMMyyyy.string(from: param.dateValue)
            case .text, .select:
                data[param.code] = String(param.value)
            case .currentDate, .hidden, .unknown:
                continue
            }
        }
        return data
    }
    
    var options: APIResourceOptions {
        var formData: (httpBody: Data?, headers: [String : String])?
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            defer {
                group.leave()
            }
            formData = multipartFormData(textParams: textParams)
        }
        group.wait()
        
        return APIResourceOptions(
            method: .POST,
            httpBody: formData?.httpBody,
            headers: formData?.headers ?? [:]
        )
    }
    
    let apiErrors: [APIResourceError<Error>] = []
}
