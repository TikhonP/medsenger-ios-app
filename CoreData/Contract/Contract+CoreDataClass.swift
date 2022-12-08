//
//  Contract+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData
import os.log

@objc(Contract)
public class Contract: NSManagedObject, CoreDataIdGetable, CoreDataErasable {
    
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Contract.self)
    )
    
    /// Clean contract that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validContractIds: The contract ids that exists in JSON from Medsenger
    ///   - context: Core Data context
    internal class func cleanRemoved(validContractIds: [Int], archive: Bool, for context: NSManagedObjectContext) {
        let fetchRequest = Contract.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "archive == %@", NSNumber(value: archive))
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "Contract fetch by archive for removing") else {
            return
        }
        for contract in fetchedResults {
            if !validContractIds.contains(Int(contract.id)) {
                context.delete(contract)
                Contract.logger.debug("Contract removed")
            }
        }
    }
}
