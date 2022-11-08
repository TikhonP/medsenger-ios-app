//
//  ClinicClassifier+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ClinicClassifier)
public class ClinicClassifier: NSManagedObject {
    private class func get(id: Int, context: NSManagedObjectContext) -> ClinicClassifier? {
        do {
            let fetchRequest = ClinicClassifier.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            let fetchedResults = try context.fetch(fetchRequest)
            if let clinicClassifier = fetchedResults.first {
                return clinicClassifier
            }
            return nil
        } catch {
            print("Get `ClinicClassifier` with id: \(id), core data task failed: ", error.localizedDescription)
            return nil
        }
    }
}

extension ClinicClassifier {
    struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
    }
    
    class func saveFromJson(data: JsonDeserializer, context: NSManagedObjectContext) -> ClinicClassifier {
        let clinicClassifier = {
            guard let clinicClassifier = get(id: data.id, context: context) else {
                return ClinicClassifier(context: context)
            }
            return clinicClassifier
        }()
        
        clinicClassifier.id = Int64(data.id)
        clinicClassifier.name = data.name
        
        PersistenceController.save(context: context)
        
        return clinicClassifier
    }
}
