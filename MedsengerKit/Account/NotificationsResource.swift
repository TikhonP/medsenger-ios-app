//
//  NotificationsResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 11.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

class NotificationsResource: APIResource {
    let emailNotify: Bool
    
    init(emailNotify: Bool) {
        self.emailNotify = emailNotify
    }
    
    typealias ModelType = EmptyModel

    let methodPath = "/notifications"
    
    lazy var params: [String: String] = {
        ["emailNotify": emailNotify ? "on" : "off"]
    }()
    
    lazy var options: APIResourceOptions = {
        let formData = multipartFormData(textParams: params)
        return APIResourceOptions(
            method: .POST,
            httpBody: formData.httpBody,
            headers: formData.headers
        )
    }()
    
    internal var apiErrors: [APIResourceError<Error>] = []
}
