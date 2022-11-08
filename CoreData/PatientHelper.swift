//
//  PatientHelper.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 01.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

//extension PatientHelper {
//    private static func getOrCreate(medsengerId: Int, context: NSManagedObjectContext, contract: UserDoctorContract) -> PatientHelper {
//        do {
//            let fetchRequest = PatientHelper.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "medsengerId == %ld && contract = %@", medsengerId, contract)
//            let fetchedResults = try context.fetch(fetchRequest)
//            if let patientHelper = fetchedResults.first {
//                return patientHelper
//            }
//            return PatientHelper(context: context)
//        }
//        catch {
//            print("Fetch core data task failed: ", error.localizedDescription)
//            return PatientHelper(context: context)
//        }
//    }
//    
//    private static func cleanRemoved(validPatientHelperIds: [Int], context: NSManagedObjectContext, contract: UserDoctorContract) {
//        do {
//            let fetchRequest = PatientHelper.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
//            let fetchedResults = try context.fetch(fetchRequest)
//            for patientHelper in fetchedResults {
//                if !validPatientHelperIds.contains(Int(patientHelper.medsengerId)) {
//                    context.delete(patientHelper)
//                }
//            }
//        }
//        catch {
//            print("Fetch core data task failed: ", error.localizedDescription)
//        }
//    }
//    
//    class func save(patientHelpers: [PatientHelperResponse], contract: UserDoctorContract, context: NSManagedObjectContext) {
//        
//        var gotPatientHelpersIds = [Int]()
//        
//        for patientHelper in patientHelpers {
//            gotPatientHelpersIds.append(patientHelper.id)
//            let patientHelperModel = getOrCreate(medsengerId: patientHelper.id, context: context, contract: contract)
//            patientHelperModel.medsengerId = Int64(patientHelper.id)
//            patientHelperModel.name = patientHelper.name
//            patientHelperModel.role = patientHelper.role
//            patientHelperModel.contract = contract
//        }
//        
//        if !gotPatientHelpersIds.isEmpty {
//            cleanRemoved(validPatientHelperIds: gotPatientHelpersIds, context: context, contract: contract)
//        }
//        
//        PersistenceController.save(context: context)
//    }
//}
