//
//  AddContractResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct AddContractRequestModel: Encodable {
    
    /// Clinic ID
    let clinic: Int
    
    /// Patient email
    let email: String
    
    /// Is patient exists
    let exists: Bool
    
    /// Patient birthday
    let birthday: Date
    
    /// Patient name
    let name: String
    
    /// Patient sex
    let sex: Sex
    
    /// Patient phone
    let phone: String
    
    /// Contract end date
    let endDate: Date
    
    /// Contract ``ClinicRule`` id
    let rule: String
    
    /// Contract ``ClinicClassifier`` id
    let classifier: String
    
    /// Contract welcome message
    let welcomeMessage: String
    
    /// Contract is video enabled
    let video: Bool
    
    /// Contract number
    let number: String
    
    var birthdayAsString: String {
        DateFormatter.ddMMyyyy.string(from: birthday)
    }
    
    var endDateAsString: String {
        DateFormatter.ddMMyyyy.string(from: endDate)
    }
    
    var params: [String: String] {
        ["clinic": "\(clinic)",
         "email": email,
         "exists": "\(exists)",
         "birthday": birthdayAsString,
         "name": name,
         "sex": sex.rawValue,
         "phone": phone,
         "end_date": endDateAsString,
         "rule": classifier,
         "classifier": classifier,
         "welcome_message": welcomeMessage,
         "video": "\(video)",
         "number": number]
    }
}

struct AddContractResource: APIResource {
    let addContractRequestModel: AddContractRequestModel
    
    typealias ModelType = EmptyModel
    
    internal var methodPath = "/add_contract"
    
    var options: APIResourceOptions {
        let formData = multipartFormData(textParams: addContractRequestModel.params)
        return APIResourceOptions(
            method: .POST,
            httpBody: formData.httpBody,
            headers: formData.headers
        )
    }
}
