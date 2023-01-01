//
//  CoreDataIdIntRemovedCleanable.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

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
    ///   - moc: Core Data context
    internal static func cleanRemoved(_ validIds: [Int], contract: Contract, for moc: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        let fetchedResults = try moc.wrappedFetch(fetchRequest, detailsForLogging: "\(Self.self) fetch by contract for removing")
        for entity in fetchedResults {
            if !validIds.contains(Int(entity.id)) {
                moc.delete(entity)
            }
        }
    }
}
