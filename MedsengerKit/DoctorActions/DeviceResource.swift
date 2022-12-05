//
//  DeviceResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

struct DeviceResource: APIResource {
    let devices: [DeviceNode]
    let contractId: Int
    
    typealias ModelType = EmptyModel
    
    var methodPath: String { "/contracts/\(contractId)/agents" }
    
    var params: [String: String] {
        var data = [String: String]()
        for device in devices {
            data["agent_\(device.id)"] = "\(device.isEnabled)"
        }
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
}
