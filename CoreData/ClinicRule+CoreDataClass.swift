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
    private class func get(id: Int, for context: NSManagedObjectContext) -> ClinicRule? {
        let fetchRequest = ClinicRule.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "ClinicRule get by id")
        return fetchedResults?.first
    }
}

extension ClinicRule {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
}

extension ClinicRule {
    struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
    }
    
    class func saveFromJson(_ data: JsonDeserializer, for context: NSManagedObjectContext) -> ClinicRule {
        let clinicRule = get(id: data.id, for: context) ?? ClinicRule(context: context)
        
        clinicRule.id = Int64(data.id)
        clinicRule.name = data.name
        
        return clinicRule
    }
}
