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
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let clinic = try get(id: id, for: moc)
            clinic.logo = image
            try moc.wrappedSave(detailsForLogging: "Clinic save logo")
        }
    }
    
    /// All Objects as array
    ///
    /// Be careful! It returns entity which can be used only on main thread.
    /// - Returns: Array of all clinics
    @MainActor public static func objectsAll() -> [Clinic] {
        let viewContext = PersistenceController.shared.container.viewContext
        var result = [Clinic]()
        viewContext.performAndWait {
            let fetchRequest = Clinic.fetchRequest()
            if let fetchedResults = try? viewContext.wrappedFetch(fetchRequest, detailsForLogging: "Clinic.hasDevices") {
                result = fetchedResults
            }
        }
        return result
    }
}
