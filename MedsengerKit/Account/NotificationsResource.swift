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

    var methodPath = "/account"
    
    var options: APIResourceOptions {
        APIResourceOptions(
            method: .POST,
            httpBody: encodeToJSON(RequestModel(emailNotify: emailNotify))
        )
    }
}
