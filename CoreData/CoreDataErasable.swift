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
    /// - Parameter moc: Core Data context
    internal static func erase(for moc: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        let fetchedResults = try moc.wrappedFetch(fetchRequest, detailsForLogging: "\(Self.self) earse")
        for entity in fetchedResults {
            moc.delete(entity)
        }
    }
}
