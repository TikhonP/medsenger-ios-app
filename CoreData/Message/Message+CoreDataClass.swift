//
//  Message+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData
import os.log

let __messagesSortDescriptors = [
    NSSortDescriptor(key: "sent", ascending: true),
    NSSortDescriptor(key: "id", ascending: true)
]

@objc(Message)
public class Message: NSManagedObject, CoreDataIdGetable {
    
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Message.self)
    )
    
    public enum ActionType: String {
        case zoom, url, action, vc
    }
    
    public static func getLastMessageForContract(for contract: Contract, for moc: NSManagedObjectContext) throws -> Message {
        let fetchRequest = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        fetchRequest.sortDescriptors = __messagesSortDescriptors
        fetchRequest.fetchLimit = 1
        let fetchedResults = try moc.wrappedFetch(fetchRequest, detailsForLogging: "getLastMessageForContract")
        guard let messsage = fetchedResults.first else {
            throw PersistenceController.ObjectNotFoundError()
        }
        return messsage
    }
    
    public static func getFirstMessageForContract(for contract: Contract, for moc: NSManagedObjectContext) throws -> Message {
        let fetchRequest = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        fetchRequest.sortDescriptors = __messagesSortDescriptors
        fetchRequest.fetchLimit = 1
        let fetchedResults = try moc.wrappedFetch(fetchRequest, detailsForLogging: "getFirstMessageForContract")
        guard let messsage = fetchedResults.first else {
            throw PersistenceController.ObjectNotFoundError()
        }
        return messsage
    }
    
    public static func markActionMessageAsUsed(id: Int) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let message = try get(id: id, for: moc)
            if message.actionOnetime {
                message.actionUsed = true
                try moc.wrappedSave(detailsForLogging: "markActionMessageAsUsed")
            }
        }
    }
    
    internal static func markNextAndPreviousMessages(for contract: Contract, for moc: NSManagedObjectContext) throws {
        let fetchRequest = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        fetchRequest.sortDescriptors = __messagesSortDescriptors
        let results = try moc.wrappedFetch(fetchRequest, detailsForLogging: "get messages for markNextAndPreviousMessages")
        let resultsArray = Array(results)
        for (index, message) in resultsArray.enumerated() {
            var offset = 1
            while let previousMessage = resultsArray[safe: index - offset] {
                if previousMessage.showMessage {
                    message.previousMessage = previousMessage
                    break
                } else {
                    offset += 1
                }
            }
        }
    }
    
    func isSameAuthor(as message: Message) -> Bool {
        message.author == author && message.isMessageSent == isMessageSent && message.authorRole == authorRole
    }
    
    var createSeparatorWithPreviousMessage: Bool {
        guard let previousMessage = previousMessage, let messageSent = sent, let previousMessageSent = previousMessage.sent else {
            return true
        }
        return !(messageSent.minutes(from: previousMessageSent) < 60 && isSameAuthor(as: previousMessage))
    }
}
