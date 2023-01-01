//
//  PersistenceController.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData
import os.log

class PersistenceController {
    
    static let shared = PersistenceController()
    
    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PersistenceController.self)
    )
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Medsenger")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                PersistenceController.logger.error("Core Data: Failed to load: \(error.localizedDescription)")
            }
        })
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    struct ObjectNotFoundError: Error {}
}

extension PersistenceController {
    
    /// Clear database with optional clearing user
    ///
    /// Use it for sign out or changing user role
    ///
    /// - Parameter withUser: clear user or not
    public class func clearDatabase(withUser: Bool) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            try? Contract.erase(for: moc)
            try? Agent.erase(for: moc)
            try? Clinic.erase(for: moc)
            if withUser {
                try? User.erase(for: moc)
            }
            try moc.wrappedSave(detailsForLogging: "PersistenceController: clearDatabase withUser: \(withUser)")
        }
    }
}
