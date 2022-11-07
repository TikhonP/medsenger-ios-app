//
//  DoctorHelper.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 01.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension DoctorHelper {
    private static func getOrCreate(medsengerId: Int, context: NSManagedObjectContext, contract: UserDoctorContract) -> DoctorHelper {
        do {
            let fetchRequest = DoctorHelper.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "medsengerId == %ld && contract = %@", medsengerId, contract)
            let fetchedResults = try context.fetch(fetchRequest)
            if let doctorHelper = fetchedResults.first {
                return doctorHelper
            }
            return DoctorHelper(context: context)
        }
        catch {
            print("Fetch core data task failed: ", error.localizedDescription)
            return DoctorHelper(context: context)
        }
    }
    
    private static func cleanRemoved(validDoctorHelpersIds: [Int], context: NSManagedObjectContext, contract: UserDoctorContract) {
        do {
            let fetchRequest = DoctorHelper.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for doctorHelper in fetchedResults {
                if !validDoctorHelpersIds.contains(Int(doctorHelper.medsengerId)) {
                    context.delete(doctorHelper)
                }
            }
        }
        catch {
            print("Fetch core data task failed: ", error.localizedDescription)
        }
    }
    
    class func save(doctorHelpers: [DoctorHelperResponse], contract: UserDoctorContract, context: NSManagedObjectContext) {
        
        var gotDoctorHelpersIds = [Int]()
        
        for doctorHelper in doctorHelpers {
            gotDoctorHelpersIds.append(doctorHelper.id)
            let doctorHelperModel = getOrCreate(medsengerId: doctorHelper.id, context: context, contract: contract)
            doctorHelperModel.medsengerId = Int64(doctorHelper.id)
            doctorHelperModel.name = doctorHelper.name
            doctorHelperModel.role = doctorHelper.role
            doctorHelperModel.contract = contract
        }
        
        if !gotDoctorHelpersIds.isEmpty {
            cleanRemoved(validDoctorHelpersIds: gotDoctorHelpersIds, context: context, contract: contract)
        }
        
        PersistenceController.save(context: context)
    }
}
