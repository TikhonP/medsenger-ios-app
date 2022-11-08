//
//  PatientHelper+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PatientHelper)
public class PatientHelper: NSManagedObject {
    private class func get(id: Int, contract: Contract, context: NSManagedObjectContext) -> PatientHelper? {
        do {
            let fetchRequest = PatientHelper.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld && contract = %@", id, contract)
            let fetchedResults = try context.fetch(fetchRequest)
            if let patientHelper = fetchedResults.first {
                return patientHelper
            }
            return nil
        } catch {
            print("Fetch `PatientHelper` with id: \(id) core data failed: \(error.localizedDescription)")
            return nil
        }
    }
}

extension PatientHelper {
    struct JsonDecoder: Decodable {
        let id: Int
        let name: String
        let role: String
    }
    
    private class func cleanRemoved(validIds: [Int], contract: Contract, context: NSManagedObjectContext) {
        do {
            let fetchRequest = PatientHelper.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for patientHelper in fetchedResults {
                if !validIds.contains(Int(patientHelper.id)) {
                    context.delete(patientHelper)
                    PersistenceController.save(context: context)
                }
            }
        } catch {
            print("Fetch `PatientHelper` core data failed: \(error.localizedDescription)")
        }
    }
    
    private class func saveFromJson(data: JsonDecoder, contract: Contract, context: NSManagedObjectContext) -> PatientHelper {
        let patientHelper = {
            guard let patientHelper = get(id: data.id, contract: contract, context: context) else {
                return PatientHelper(context: context)
            }
            return patientHelper
        }()
        
        patientHelper.id = Int64(data.id)
        patientHelper.name = data.name
        patientHelper.role = data.role
        
        PersistenceController.save(context: context)
        
        return patientHelper
    }
    
    class func saveFromJson(data: [JsonDecoder], contract: Contract, context: NSManagedObjectContext) -> [PatientHelper] {
        var validIds = [Int]()
        var patientHelpers = [PatientHelper]()
        
        for patientHelperData in data {
            let patientHelper = saveFromJson(data: patientHelperData, contract: contract, context: context)
            
            validIds.append(patientHelperData.id)
            patientHelpers.append(patientHelper)
        }
        
        if !validIds.isEmpty {
            cleanRemoved(validIds: validIds, contract: contract, context: context)
        }
        
        return patientHelpers
    }
}
