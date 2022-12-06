//
//  ClinicScenario+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension ClinicScenario {
    public struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
        let description: String
        let category: String
        let params: Array<ClinicScenarioParam.JsonDeserializer>?
    }
    
    private static func saveFromJson(_ data: JsonDeserializer, clinic: Clinic, for context: NSManagedObjectContext) -> ClinicScenario {
        let clinicScenario = get(id: data.id, for: context) ?? ClinicScenario(context: context)
        
        clinicScenario.id = Int64(data.id)
        clinicScenario.name = data.name
        clinicScenario.scenarioDescription = data.description
        clinicScenario.category = data.category
        clinicScenario.clinic = clinic
        
        if let params = data.params {
            ClinicScenarioParam.saveFromJson(params, scenario: clinicScenario, for: context)
        }
        
        return clinicScenario
    }
    
    public static func saveFromJson(_ data: [JsonDeserializer], clinic: Clinic, for context: NSManagedObjectContext) {
        for scenarioData in data {
            _ = saveFromJson(scenarioData, clinic: clinic, for: context)
        }
    }
}

