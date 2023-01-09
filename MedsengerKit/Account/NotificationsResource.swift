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

    let methodPath = "/notifications"
    
    var params: [String: String] {
        ["emailNotify": emailNotify ? "on" : "off"]
    }
    
    var options: APIResourceOptions {
        let formData = multipartFormData(textParams: params)
        return APIResourceOptions(
            method: .POST,
            httpBody: formData.httpBody,
            headers: formData.headers
        )
    }
    
    let apiErrors: [APIResourceError<Error>] = []
}
