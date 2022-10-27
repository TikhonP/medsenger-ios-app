//
//  PersistenceController.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Medsenger")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    class func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Core Data failed to save model: \(error.localizedDescription)")
        }
    }

}
