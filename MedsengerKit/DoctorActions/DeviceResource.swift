//
//  DeviceResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

class DeviceResource: APIResource {
    let devices: [DeviceNode]
    let contractId: Int
    
    init(devices: [DeviceNode], contractId: Int) {
        self.devices = devices
        self.contractId = contractId
    }
    
    typealias ModelType = EmptyModel
    
    lazy var methodPath: String = { "/contracts/\(contractId)/agents" }()
    
    lazy var params: [String: String] = {
        var data = [String: String]()
        for device in devices {
            data["agent_\(device.id)"] = "\(device.isEnabled)"
        }
        return data
    }()
    
    lazy var options: APIResourceOptions = {
        let result = multipartFormData(textParams: params)
        return APIResourceOptions(
            method: .POST,
            httpBody: result.httpBody,
            headers: result.headers
        )
    }()
    
    internal var apiErrors: [APIResourceError<Error>] = []
}
