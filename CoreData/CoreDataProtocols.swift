//
//  CoreDataProtocols.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
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
    internal static func get(name: String, contract: Contract, for context: NSManagedObjectContext) -> Self? {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
        fetchRequest.fetchLimit = 1
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "\(Self.self) get by name and contract")
        return fetchedResults?.first
    }
}

/// Imaplements functions for cleaning removed entities by name with data from Medsenger server
protocol CoreDataNameStringRemovedCleanable: NSManagedObject {
    var name: String? { get }
    var contract: Contract? { get }
}

extension CoreDataNameStringRemovedCleanable {
    
    /// Clean entities that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validNames: The entities names that exists in JSON from Medsenger
    ///   - contract: UserDoctorContract contract for data filtering
    ///   - context: Core Data context
    internal static func cleanRemoved(_ validNames: [String], contract: Contract, for context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "\(Self.self) fetch by contract for removing") else {
            return
        }
        for entity in fetchedResults {
            if let name = entity.name, !validNames.contains(name) {
                context.delete(entity)
            }
        }
    }
}

/// Imaplements functions for cleaning removed entities by id with data from Medsenger server
protocol CoreDataIdIntRemovedCleanable: NSManagedObject {
    var id: Int64 { get }
    var contract: Contract? { get }
}

extension CoreDataIdIntRemovedCleanable {
    
    /// Clean entities that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validIds: The entities ids that exists in JSON from Medsenger
    ///   - contract: UserDoctorContract contract for data filtering
    ///   - context: Core Data context
    internal static func cleanRemoved(_ validIds: [Int], contract: Contract, for context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "\(Self.self) fetch by contract for removing") else {
            return
        }
        for entity in fetchedResults {
            if !validIds.contains(Int(entity.id)) {
                context.delete(entity)
            }
        }
    }
}

protocol CoreDataErasable: NSManagedObject {}

extension CoreDataErasable{
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
