//
//  SignInResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

struct LoginData {
    let email: String
    let password: String
    
    let uuid = UIDevice.current.identifierForVendor?.uuidString
    static let manufacturer = "Apple"
    let platform = UIDevice.current.systemVersion
    let model = {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }()
    
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "manufacturer", value: LoginData.manufacturer),
            URLQueryItem(name: "platform", value: platform),
            URLQueryItem(name: "model", value: model),
        ]
    }
}

struct SignInResource: APIResource {
    let email: String
    let password: String

    typealias ModelType = User.JsonDecoder

    var methodPath = "/auth"
    
    var options: APIResourceOptions {
        APIResourceOptions(
            dateDecodingStrategy: .secondsSince1970,
            parseResponse: true,
            headers: [
                "Cache-Control": "no-store; no-cache; must-revalidate"
            ],
            queryItems: LoginData(email: email, password: password).queryItems,
            addApiKey: false
        )
    }
}


