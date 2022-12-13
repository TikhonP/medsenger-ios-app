//
//  Message+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData
import os.log

@objc(Message)
public class Message: NSManagedObject, CoreDataIdGetable {
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Message.self)
    )
    
    public static func getLastMessageForContract(for contract: Contract, for context: NSManagedObjectContext) -> Message? {
        let fetchRequest = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sent", ascending: false)]
        fetchRequest.fetchLimit = 1
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "getLastMessageForContract")
        return fetchedResults?.first
    }
    
    public static func getFirstMessageForContract(for contract: Contract, for context: NSManagedObjectContext) -> Message? {
        let fetchRequest = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sent", ascending: true)]
        fetchRequest.fetchLimit = 1
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "getFirstMessageForContract")
        return fetchedResults?.first
    }
}
