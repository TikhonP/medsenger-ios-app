//
//  ClinicScenario+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ClinicScenario)
public class ClinicScenario: NSManagedObject {
    private class func get(id: Int, for context: NSManagedObjectContext) -> ClinicScenario? {
        let fetchRequest = ClinicScenario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "ClinicScenario get by id")
        return fetchedResults?.first
    }
}

extension ClinicScenario {
    struct JsonDeserializer: Decodable {
        struct Param: Decodable {
            let type: String
            let code: String
        }
        
        let id: Int
        let name: String
        let description: String
        let category: String
        let params: Array<Param>?
    }
    
    private class func saveFromJson(_ data: JsonDeserializer, clinic: Clinic, for context: NSManagedObjectContext) -> ClinicScenario {
        let clinicScenario = get(id: data.id, for: context) ?? ClinicScenario(context: context)
        
        clinicScenario.id = Int64(data.id)
        clinicScenario.name = data.name
        clinicScenario.scenarioDescription = data.description
        clinicScenario.category = data.category
        clinicScenario.clinic = clinic
        
        return clinicScenario
    }
    
    class func saveFromJson(_ data: [JsonDeserializer], clinic: Clinic, for context: NSManagedObjectContext) {
        for scenarioData in data {
            _ = saveFromJson(scenarioData, clinic: clinic, for: context)
        }
    }
}

