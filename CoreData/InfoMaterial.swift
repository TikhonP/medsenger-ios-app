//
//  InfoMaterial.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 01.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

//extension InfoMaterial {
//    private static func getOrCreate(name: String, context: NSManagedObjectContext, contract: UserDoctorContract) -> InfoMaterial {
//        do {
//            let fetchRequest = InfoMaterial.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
//            let fetchedResults = try context.fetch(fetchRequest)
//            if let infoMaterial = fetchedResults.first {
//                return infoMaterial
//            }
//            return InfoMaterial(context: context)
//        }
//        catch {
//            print("Fetch core data task failed: ", error.localizedDescription)
//            return InfoMaterial(context: context)
//        }
//    }
//    
//    private static func cleanRemoved(validInfoMaterialNames: [String], context: NSManagedObjectContext, contract: UserDoctorContract) {
//        do {
//            let fetchRequest = InfoMaterial.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
//            let fetchedResults = try context.fetch(fetchRequest)
//            for infoMaterial in fetchedResults {
//                if let name = infoMaterial.name, !validInfoMaterialNames.contains(name) {
//                    context.delete(infoMaterial)
//                }
//            }
//        }
//        catch {
//            print("Fetch core data task failed: ", error.localizedDescription)
//        }
//    }
//    
//    class func save(infoMaterials: [InfoMaterialResponse], contract: UserDoctorContract, context: NSManagedObjectContext) {
//        var gotInfoMaterialNames = [String]()
//        
//        for infoMaterial in infoMaterials {
//            gotInfoMaterialNames.append(infoMaterial.name)
//            let infoMaterialModel = getOrCreate(name: infoMaterial.name, context: context, contract: contract)
//            infoMaterialModel.name = infoMaterial.name
//            infoMaterialModel.link = infoMaterial.link
//            infoMaterialModel.contract = contract
//        }
//        
//        if !gotInfoMaterialNames.isEmpty {
//            cleanRemoved(validInfoMaterialNames: gotInfoMaterialNames, context: context, contract: contract)
//        }
//        
//        PersistenceController.save(context: context)
//    }
//}
