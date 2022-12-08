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
    public static func saveLogo(id: Int, image: Data) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let clinic = get(id: id, for: context)
            clinic?.logo = image
            PersistenceController.save(for: context, detailsForLogging: "Clinic save logo")
        }
    }
    
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
