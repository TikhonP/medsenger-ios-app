//
//  DoctorHelper+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(DoctorHelper)
public class DoctorHelper: NSManagedObject {
    private class func get(id: Int, for context: NSManagedObjectContext) -> DoctorHelper? {
        let fetchRequest = DoctorHelper.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "DoctorHelper get by id")
        return fetchedResults?.first
    }
}

extension DoctorHelper {
    struct JsonDecoder: Decodable {
        let id: Int
        let name: String
        let role: String
    }
    
    private class func cleanRemoved(validIds: [Int], contract: Contract, for context: NSManagedObjectContext) {
        let fetchRequest = DoctorHelper.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "DoctorHelper fetch by contract for removing") else {
            return
        }
        for doctorHelper in fetchedResults {
            if !validIds.contains(Int(doctorHelper.id)) {
                context.delete(doctorHelper)
            }
        }
    }
    
    private class func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> DoctorHelper {
        let doctorHelper = get(id: data.id, for: context) ?? DoctorHelper(context: context)
        
        doctorHelper.id = Int64(data.id)
        doctorHelper.name = data.name
        doctorHelper.role = data.role
        doctorHelper.contract = contract
        
        return doctorHelper
    }
    
    class func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [DoctorHelper] {
        var validIds = [Int]()
        var doctorHelpers = [DoctorHelper]()
        
        for doctorHelperData in data {
            let doctorHelper = saveFromJson(doctorHelperData, contract: contract, for: context)
            
            validIds.append(doctorHelperData.id)
            doctorHelpers.append(doctorHelper)
        }
        
        if !validIds.isEmpty {
            cleanRemoved(validIds: validIds, contract: contract, for: context)
        }
        
        return doctorHelpers
    }
}
