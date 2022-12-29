//
//  CoreDataStringContractGetable.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

/// Implements functions for retrieving entity by name property
protocol CoreDataStringContractGetable: NSManagedObject {
    var name: String? { get }
    var contract: Contract? { get }
}

extension CoreDataStringContractGetable {
    
    /// Get entity by name and contract in the managed context
    /// - Parameters:
    ///   - name: Name of the entity.
    ///   - contract: Related contract.
    ///   - context: Managed object context.
    /// - Returns: Entity
    internal static func get(name: String, contract: Contract, for context: NSManagedObjectContext) throws -> Self {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .managedObjectResultType
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "\(Self.self) get by name and contract")
        guard let object = fetchedResults?.first else {
            throw PersistenceController.ObjectNotFoundError()
        }
        return object
    }
}
