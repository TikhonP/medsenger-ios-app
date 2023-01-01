//
//  ClinicRule+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension ClinicRule {
    public struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
    }
    
    public static func saveFromJson(_ data: JsonDeserializer, for moc: NSManagedObjectContext) -> ClinicRule {
        let clinicRule = (try? get(id: data.id, for: moc)) ?? ClinicRule(context: moc)
        
        clinicRule.id = Int64(data.id)
        clinicRule.name = data.name
        
        return clinicRule
    }
}
