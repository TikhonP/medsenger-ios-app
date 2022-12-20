//
//  CoreDataIdGetable.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

/// Implements functions for retrieving entity by id property
protocol CoreDataIdGetable: NSManagedObject {
    var id: Int64 { get }
}

extension CoreDataIdGetable {
    
    /// Get entity by id in the managed context
    /// - Parameters:
    ///   - id: Id of the entity.
    ///   - context: Managed object context.
    /// - Returns: Entity
    internal static func get(id: Int, for context: NSManagedObjectContext) -> Self? {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        fetchRequest.fetchLimit = 1
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "\(Self.self) get by id")
        return fetchedResults?.first
    }
    
    /// Get entity by id
    /// - Parameter id: Id of the entity.
    /// - Returns: Entity
    public static func get(id: Int) -> Self? {
        let context = PersistenceController.shared.container.viewContext
        var entity: Self?
        context.performAndWait {
            entity = get(id: id, for: context)
        }
        return entity
    }
}
