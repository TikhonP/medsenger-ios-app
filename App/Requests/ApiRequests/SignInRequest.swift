//
//  SignInRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 25.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

struct Login: QueryItems {
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
            URLQueryItem(name: "manufacturer", value: Login.manufacturer),
            URLQueryItem(name: "platform", value: platform),
            URLQueryItem(name: "model", value: model),
        ]
    }
}

struct SignInResponse: Decodable {
    let api_token: String
    let isDoctor: Bool
    let isPatient: Bool
    let name: String
    //    let clinics: Array<getTokenResponseDataClinic>
    let email: String?
    let birthday: String
    let phone: String?
    let short_name: String
    let hasPhoto: Bool
    let email_notifications: Bool
    
    func saveUser() {
        let dateFormatter = DateFormatter.ddMMyyyy
        let birthday = dateFormatter.date(from: birthday)!
        PersistenceController.saveUser(isDoctor: isDoctor, isPatient: isPatient, name: name, email: email, birthday: birthday, phone: phone, shortName: short_name, hasPhoto: hasPhoto, emailNotifications: email_notifications)
    }
}

struct SignInResource: APIResource {   
    let email: String
    let password: String

    typealias ModelType = SignInResponse
    
    var parseResponse = true
    var httpBody: Data? = nil
    var httpMethod: String = "GET"
    var headers: [String : String]? = [
        "Cache-Control": "no-store; no-cache; must-revalidate"
    ]
    var methodPath = "/auth"
    var queryItems: [URLQueryItem]? { Login(email: email, password: password).queryItems }
    var addApiKey = false
}

extension DateFormatter {
    static let ddMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
}

