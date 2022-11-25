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
                print("Core Data: Failed to load: \(error.localizedDescription)")
            }
        })
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    /// Save persistence store
    /// - Parameters:
    ///   - context: Managed object context
    ///   - detailsForLogging: if error appears while saving provide object that saved for logging and debugging
    public class func save(for context: NSManagedObjectContext, detailsForLogging: String? = nil) {
        if let detailsForLogging = detailsForLogging {
            print("Core Data: Called save: \(detailsForLogging)")
        } else {
            print("Core Data: Called save")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch let nserror as NSError {
                if let detailsForLogging = detailsForLogging {
                    print("Core Data: Failed to save model `\(detailsForLogging)`: \(nserror.localizedDescription)")
                } else {
                    print("Core Data: Failed to save model: \(nserror.localizedDescription)")
                }
                if let detailed = nserror.userInfo["NSDetailedErrors"] as? NSMutableArray {
                    for nserror in detailed {
                        if let nserror = nserror as? NSError, let entity = nserror.userInfo["NSValidationErrorObject"] {
                            print("Core Data: Detailed: \(nserror.localizedDescription) Entity: `\(type(of: entity))`.")
                        }
                    }
                }
            }
        }
    }
    
    /// Perform fetch request with errors catching
    /// - Parameters:
    ///   - request: The fetch request that specifies the search criteria.
    ///   - context: Managed object context
    ///   - detailsForLogging: if error appears while fetching provide object that saved for logging and debugging
    /// - Returns: Returns an array of items of the specified type that meet the fetch request’s critieria nil value returned if error
    public class func fetch<T>(_ request: NSFetchRequest<T>, for context: NSManagedObjectContext, detailsForLogging: String? = nil) -> [T]? where T : NSFetchRequestResult {
        do {
            return try context.fetch(request)
        } catch let nserror as NSError {
            if let detailsForLogging = detailsForLogging {
                print("Core Data: Failed to perform fetch request `\(detailsForLogging)`: \(nserror.localizedDescription)")
            } else {
                print("Core Data: Failed to perform fetch request: \(nserror.localizedDescription)")
            }
            return nil
        }
    }
    
    public class func clearDatabase() {
        guard let url = PersistenceController.shared.container.persistentStoreDescriptions.first?.url else { return }
        
        let persistentStoreCoordinator = PersistenceController.shared.container.persistentStoreCoordinator
        
        do {
            try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print("Core Data: Failed to clear persistent store: \(error.localizedDescription)")
        }
    }
}
