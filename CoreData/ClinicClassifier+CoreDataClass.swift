//
//  ClinicClassifier+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(ClinicClassifier)
public class ClinicClassifier: NSManagedObject {
    private class func get(id: Int, for context: NSManagedObjectContext) -> ClinicClassifier? {
        let fetchRequest = ClinicClassifier.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "ClinicClassifier get by id")
        return fetchedResults?.first
    }
}

extension ClinicClassifier {
    public var wrappedName: String {
        name ?? "Unknown name" 
    }
}

extension ClinicClassifier {
    struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
    }
    
    class func saveFromJson(_ data: JsonDeserializer, for context: NSManagedObjectContext) -> ClinicClassifier {
        let clinicClassifier = get(id: data.id, for: context) ?? ClinicClassifier(context: context)
        
        clinicClassifier.id = Int64(data.id)
        clinicClassifier.name = data.name
        
        return clinicClassifier
    }
}
