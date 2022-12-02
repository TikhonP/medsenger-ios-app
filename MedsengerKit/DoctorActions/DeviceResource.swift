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
    
    var httpBody: Data? {
        var data = [String: Bool]()
        for device in devices {
            data["agent_\(device.id)"] = device.isEnabled
        }
        do {
            return try JSONSerialization.data(withJSONObject: data)
        } catch {
            Logger.urlRequest.error("DeviceResource: Failed to serialize JSON data: \(error.localizedDescription)")
            return nil
        }
    }
    
    var options: APIResourceOptions {
        APIResourceOptions(
            method: .POST,
            httpBody: httpBody
        )
    }
}
