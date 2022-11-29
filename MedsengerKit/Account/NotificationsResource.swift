//
//  NotificationsResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 11.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

struct NotificationsResource: APIResource {
    let emailNotify: Bool
    
    typealias ModelType = EmptyModel
    
    struct RequestModel: Encodable {
        let emailNotify: Bool
    }
    
    var httpBody: Data? {
        do {
            let data = try JSONEncoder().encode(
                RequestModel(emailNotify: emailNotify))
            return data
        } catch {
            Logger.urlRequest.error("Failed to encode notification resource data: \(error.localizedDescription)")
            return nil
        }
    }

    var methodPath = "/account"
    
    var options: APIResourceOptions {
        APIResourceOptions(
            httpBody: httpBody,
            httpMethod: .POST
        )
    }
}
