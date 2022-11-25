//
//  PatientHelper+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(PatientHelper)
public class PatientHelper: NSManagedObject {
    private class func get(id: Int, for context: NSManagedObjectContext) -> PatientHelper? {
        let fetchRequest = PatientHelper.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "PatientHelper get by id")
        return fetchedResults?.first
    }
}

extension PatientHelper {
    struct JsonDecoder: Decodable {
        let id: Int
        let name: String
        let role: String
    }
    
    private class func cleanRemoved(validIds: [Int], contract: Contract, for context: NSManagedObjectContext) {
        let fetchRequest = PatientHelper.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "PatientHelper fetch by contract for removing") else {
            return
        }
        for patientHelper in fetchedResults {
            if !validIds.contains(Int(patientHelper.id)) {
                context.delete(patientHelper)
            }
        }
    }
    
    private class func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> PatientHelper {
        let patientHelper = get(id: data.id, for: context) ?? PatientHelper(context: context)
        
        patientHelper.id = Int64(data.id)
        patientHelper.name = data.name
        patientHelper.role = data.role
        patientHelper.contract = contract
        
        return patientHelper
    }
    
    class func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [PatientHelper] {
        var validIds = [Int]()
        var patientHelpers = [PatientHelper]()
        
        for patientHelperData in data {
            let patientHelper = saveFromJson(patientHelperData, contract: contract, for: context)
            
            validIds.append(patientHelperData.id)
            patientHelpers.append(patientHelper)
        }
        
        if !validIds.isEmpty {
            cleanRemoved(validIds: validIds, contract: contract, for: context)
        }
        
        return patientHelpers
    }
}
