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
    internal static func get(id: Int, for context: NSManagedObjectContext) throws -> Self {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        fetchRequest.fetchLimit = 1
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "\(Self.self) get by id")
        guard let object = fetchedResults?.first else {
            throw PersistenceController.ObjectNotFoundError()
        }
        return object
    }
    
    /// Get entity by id
    ///
    /// Be careful! It returns entity which can be used only on main thread.
    /// - Parameter id: Id of the entity.
    /// - Returns: Entity
    @MainActor public static func get(id: Int) async throws -> Self {
        let context = PersistenceController.shared.container.viewContext
        return try await context.crossVersionPerform {
            try get(id: id, for: context)
        }
    }
}
