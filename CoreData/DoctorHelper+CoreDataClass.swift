//
//  DoctorHelper+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(DoctorHelper)
public class DoctorHelper: NSManagedObject {
    private class func get(id: Int, contract: Contract, context: NSManagedObjectContext) -> DoctorHelper? {
        do {
            let fetchRequest = DoctorHelper.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld && contract = %@", id, contract)
            let fetchedResults = try context.fetch(fetchRequest)
            if let doctorHelper = fetchedResults.first {
                return doctorHelper
            }
            return nil
        } catch {
            print("Fetch `DoctorHelper` core data task failed: \(error.localizedDescription)")
            return nil
        }
    }
}

extension DoctorHelper {
    struct JsonDecoder: Decodable {
        let id: Int
        let name: String
        let role: String
    }
    
    private class func cleanRemoved(validIds: [Int], contract: Contract, context: NSManagedObjectContext) {
        do {
            let fetchRequest = DoctorHelper.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for doctorHelper in fetchedResults {
                if !validIds.contains(Int(doctorHelper.id)) {
                    context.delete(doctorHelper)
                    PersistenceController.save(context: context)
                }
            }
        } catch {
            print("Fetch core data task failed: ", error.localizedDescription)
        }
    }
    
    private class func saveFromJson(data: JsonDecoder, contract: Contract, context: NSManagedObjectContext) -> DoctorHelper {
        let doctorHelper = {
            guard let doctorHelper = get(id: data.id, contract: contract, context: context) else {
                return DoctorHelper(context: context)
            }
            return doctorHelper
        }()
        
        doctorHelper.id = Int64(data.id)
        doctorHelper.name = data.name
        doctorHelper.role = data.role
        
        PersistenceController.save(context: context)
        
        return doctorHelper
    }
    
    class func saveFromJson(data: [JsonDecoder], contract: Contract, context: NSManagedObjectContext) -> [DoctorHelper] {
        var validIds = [Int]()
        var doctorHelpers = [DoctorHelper]()
        
        for doctorHelperData in data {
            let doctorHelper = saveFromJson(data: doctorHelperData, contract: contract, context: context)
            
            validIds.append(doctorHelperData.id)
            doctorHelpers.append(doctorHelper)
        }
        
        if !validIds.isEmpty {
            cleanRemoved(validIds: validIds, contract: contract, context: context)
        }
        
        return doctorHelpers
    }
}
