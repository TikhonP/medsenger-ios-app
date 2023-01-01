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
    
    private static func saveFromJson(_ data: JsonDecoder, contract: Contract, for moc: NSManagedObjectContext) -> DoctorHelper {
        let doctorHelper = (try? get(id: data.id, for: moc)) ?? DoctorHelper(context: moc)
        
        doctorHelper.id = Int64(data.id)
        doctorHelper.name = data.name
        doctorHelper.role = data.role
        doctorHelper.contract = contract
        
        return doctorHelper
    }
    
    public static func saveFromJson(_ data: [JsonDecoder], contract: Contract, for moc: NSManagedObjectContext) throws -> [DoctorHelper] {
        var validIds = [Int]()
        var doctorHelpers = [DoctorHelper]()
        
        for doctorHelperData in data {
            let doctorHelper = saveFromJson(doctorHelperData, contract: contract, for: moc)
            
            validIds.append(doctorHelperData.id)
            doctorHelpers.append(doctorHelper)
        }
        
        if !validIds.isEmpty {
            try cleanRemoved(validIds, contract: contract, for: moc)
        }
        
        return doctorHelpers
    }
}
