//
//  Clinic+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(Clinic)
public class Clinic: NSManagedObject, CoreDataIdGetable, CoreDataErasable {
    public static func saveLogo(id: Int, image: Data) async throws {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        try await context.crossVersionPerform {
            let clinic = try get(id: id, for: context)
            clinic.logo = image
            PersistenceController.save(for: context, detailsForLogging: "Clinic save logo")
        }
    }
    
    /// All Objects as array
    ///
    /// Be careful! It returns entity which can be used only on main thread.
    /// - Returns: Array of all clinics
    public static func objectsAll() -> [Clinic] {
        let context = PersistenceController.shared.container.viewContext
        var result = [Clinic]()
        context.performAndWait {
            let fetchRequest = Clinic.fetchRequest()
            if let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "Clinic.hasDevices") {
                result = fetchedResults
            }
        }
        return result
    }
}
