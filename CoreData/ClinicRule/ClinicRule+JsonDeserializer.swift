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
    
    public static func saveFromJson(_ data: JsonDeserializer, for context: NSManagedObjectContext) -> ClinicRule {
        let clinicRule = (try? get(id: data.id, for: context)) ?? ClinicRule(context: context)
        
        clinicRule.id = Int64(data.id)
        clinicRule.name = data.name
        
        return clinicRule
    }
}
