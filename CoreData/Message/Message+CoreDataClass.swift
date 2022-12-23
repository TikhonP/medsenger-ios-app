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
    
    public enum ActionType: String {
        case zoom, url, action
    }
    
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
    
    public static func markActionMessageAsUsed(id: Int) {
        PersistenceController.shared.container.performBackgroundTask { context in
            guard let message = get(id: id, for: context), message.actionOnetime else {
                return
            }
            message.actionUsed = true
            PersistenceController.save(for: context, detailsForLogging: "markActionMessageAsUsed")
        }
    }
    
    internal static func markNextAndPreviousMessages(for contract: Contract, for context: NSManagedObjectContext) {
        let fetchRequest = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sent", ascending: true)]
        guard let results = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "get messages for markNextAndPreviousMessages") else {
            return
        }
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
