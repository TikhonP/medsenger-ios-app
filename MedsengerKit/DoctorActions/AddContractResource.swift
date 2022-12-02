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
}

struct AddContractResource: APIResource {
    let addContractRequestModel: AddContractRequestModel
    
    typealias ModelType = EmptyModel
    
    internal var methodPath = "/add_contract"
    
    var options: APIResourceOptions {
        APIResourceOptions(
            method: .POST,
            httpBody: encodeToJSON(addContractRequestModel,
                                   dateEncodingStrategy: .formatted(DateFormatter.ddMMyyyy),
                                   keyEncodingStrategy: .convertToSnakeCase)
        )
    }
}
