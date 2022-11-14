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
    
    public class func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch let nserror as NSError {
                print("Core Data failed to save model: \(nserror.localizedDescription)")
                if let detailed = nserror.userInfo["NSDetailedErrors"] as? NSMutableArray {
                    for nserror in detailed {
                        if let nserror = nserror as? NSError, let entity = nserror.userInfo["NSValidationErrorObject"] {
                            print("Core Data Detailed: \(nserror.localizedDescription) Entity: `\(type(of: entity))`.")
                        }
                    }
                }
            }
        }
    }
    
    public class func clearDatabase() {
        guard let url = PersistenceController.shared.container.persistentStoreDescriptions.first?.url else { return }
        
        let persistentStoreCoordinator = PersistenceController.shared.container.persistentStoreCoordinator
        
        do {
            try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print("Attempted to clear persistent store: " + error.localizedDescription)
        }
    }
}
