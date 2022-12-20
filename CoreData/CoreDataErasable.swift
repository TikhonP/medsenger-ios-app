//
//  CoreDataErasable.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

/// Implements functions for earsing all entaties
protocol CoreDataErasable: NSManagedObject {}

extension CoreDataErasable {
    
    /// Earse all entities
    /// - Parameter context: Core Data context
    internal static func erase(for context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "\(Self.self) earse") else {
            return
        }
        for entity in fetchedResults {
            context.delete(entity)
        }
    }
}
