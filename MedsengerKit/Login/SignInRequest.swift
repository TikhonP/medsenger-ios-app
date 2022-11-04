//
//  SignInRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 25.10.2022.
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

struct ClinicDataResponse: Decodable {
    struct Rule: Decodable {
        let id: Int
        let name: String
    }
    
    struct Classifier: Decodable {
        let id: Int
        let name: String
    }
    
    let name: String
    let id: Int
    let video_enabled: Bool
    let esia_enabled: Bool
    let delayed_contracts_enabled: Bool
    
    let rules: Array<Rule>
    let classifiers: Array<Classifier>
    
    
}

struct SignInResponse: Decodable {
    let api_token: String
    let isDoctor: Bool
    let isPatient: Bool
    let name: String
    let clinics: Array<ClinicDataResponse>
    let email: String?
    let birthday: String
    let phone: String?
    let short_name: String
    let hasPhoto: Bool
    let email_notifications: Bool
    let hasApp: Bool
    let last_health_sync: Date?
    
    func saveUser() {
        let dateFormatter = DateFormatter.ddMMyyyy
        let birthday = dateFormatter.date(from: birthday)!
        User.save(isDoctor: isDoctor, isPatient: isPatient, name: name, email: email, birthday: birthday, phone: phone, shortName: short_name, hasPhoto: hasPhoto, emailNotifications: email_notifications)
        for clinic in clinics {
            Clinic.saveFromCheck(clinic)
        }
    }
}

struct SignInResource: APIResource {   
    let email: String
    let password: String

    typealias ModelType = SignInResponse

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

