//
//  PatientHelper+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension PatientHelper {
    struct JsonDecoder: Decodable {
        let id: Int
        let name: String
        let role: String
    }
    
    private class func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> PatientHelper {
        let patientHelper = get(id: data.id, for: context) ?? PatientHelper(context: context)
        
        patientHelper.id = Int64(data.id)
        patientHelper.name = data.name
        patientHelper.role = data.role
        patientHelper.contract = contract
        
        return patientHelper
    }
    
    class func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [PatientHelper] {
        var validIds = [Int]()
        var patientHelpers = [PatientHelper]()
        
        for patientHelperData in data {
            let patientHelper = saveFromJson(patientHelperData, contract: contract, for: context)
            
            validIds.append(patientHelperData.id)
            patientHelpers.append(patientHelper)
        }
        
        if !validIds.isEmpty {
            cleanRemoved(validIds, contract: contract, for: context)
        }
        
        return patientHelpers
    }
}
