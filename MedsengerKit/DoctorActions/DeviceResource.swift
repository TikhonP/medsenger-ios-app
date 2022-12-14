//
//  DeviceResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct DeviceResource: APIResource {
    let devices: [DeviceNode]
    let contractId: Int
    
    init(devices: [DeviceNode], contractId: Int) {
        self.devices = devices
        self.contractId = contractId
    }
    
    typealias ModelType = EmptyModel
    
    var methodPath: String { "/contracts/\(contractId)/agents" }
    
    var params: [String: String] {
        var data = [String: String]()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            for device in self.devices {
                data["agent_\(device.id)"] = "\(device.isEnabled)"
            }
            group.leave()
        }
        group.wait()
        return data
    }
    
    var options: APIResourceOptions {
        let result = multipartFormData(textParams: params)
        return APIResourceOptions(
            method: .POST,
            httpBody: result.httpBody,
            headers: result.headers
        )
    }
    
    let apiErrors: [APIResourceError<Error>] = []
}
