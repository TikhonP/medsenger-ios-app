//
//  ClinicRule+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(ClinicRule)
public class ClinicRule: NSManagedObject {
    private class func get(id: Int, context: NSManagedObjectContext) -> ClinicRule? {
        do {
            let fetchRequest = ClinicRule.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            let fetchedResults = try context.fetch(fetchRequest)
            if let clinicRule = fetchedResults.first {
                return clinicRule
            }
            return nil
        } catch {
            print("Get `ClinicRule` with id: \(id), core data task failed: ", error.localizedDescription)
            return nil
        }
    }
}

extension ClinicRule {
    struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
    }
    
    class func saveFromJson(data: JsonDeserializer, context: NSManagedObjectContext) -> ClinicRule {
        let clinicRule = {
            guard let clinicRule = get(id: data.id, context: context) else {
                return ClinicRule(context: context)
            }
            return clinicRule
        }()
        
        clinicRule.id = Int64(data.id)
        clinicRule.name = data.name
        
        PersistenceController.save(context: context)
        
        return clinicRule
    }
}
