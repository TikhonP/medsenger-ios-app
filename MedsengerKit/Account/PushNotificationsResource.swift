//
//  PushNotificationsResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 29.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct PushNotificationsResource: APIResource {
    let fcmToken: String
    
    /// Store or remove token from remote, if true save token, otherwise remove
    let store: Bool
    
    typealias ModelType = EmptyModel
    
    var methodPath: String {
        "/\(UserDefaults.userRole.rawValue)/android\(store ? "" : "/remove")"
    }
    
    var params: [String: String] {
        ["key": fcmToken]
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
