//
//  DoctorHelper+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension DoctorHelper {
    public struct JsonDecoder: Decodable {
        let id: Int
        let name: String
        let role: String
    }
    
    private static func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> DoctorHelper {
        let doctorHelper = (try? get(id: data.id, for: context)) ?? DoctorHelper(context: context)
        
        doctorHelper.id = Int64(data.id)
        doctorHelper.name = data.name
        doctorHelper.role = data.role
        doctorHelper.contract = contract
        
        return doctorHelper
    }
    
    public static func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [DoctorHelper] {
        var validIds = [Int]()
        var doctorHelpers = [DoctorHelper]()
        
        for doctorHelperData in data {
            let doctorHelper = saveFromJson(doctorHelperData, contract: contract, for: context)
            
            validIds.append(doctorHelperData.id)
            doctorHelpers.append(doctorHelper)
        }
        
        if !validIds.isEmpty {
            cleanRemoved(validIds, contract: contract, for: context)
        }
        
        return doctorHelpers
    }
}
