//
//  AccountRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct CheckResponse: Decodable {
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

struct CheckResource: APIResource {
    typealias ModelType = CheckResponse
    
    var parseResponse = true
    var httpBody: Data? = nil
    var httpMethod: String = "GET"
    var headers: [String : String]? = nil
    var methodPath = "/check"
    var queryItems: [URLQueryItem]? = nil
    var addApiKey = true
}

