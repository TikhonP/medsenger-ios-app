//
//  PushNotificationsResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 29.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class PushNotificationsResource: APIResource {
    let fcmToken: String
    
    /// Store or remove token from remote, if true save token, otherwise remove
    let store: Bool
    
    init(fcmToken: String, store: Bool) {
        self.fcmToken = fcmToken
        self.store = store
    }
    
    typealias ModelType = EmptyModel
    
    lazy var methodPath: String = {
        "/\(UserDefaults.userRole.rawValue)/android\(store ? "" : "/remove")"
    }()
    
    lazy var params: [String: String] = {
        ["key": fcmToken]
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
