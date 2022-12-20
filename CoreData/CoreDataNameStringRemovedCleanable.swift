//
//  CoreDataNameStringRemovedCleanable.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

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
