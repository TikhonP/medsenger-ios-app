//
//  Contract+publicClassMethods.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension Contract {
    public static func get(id: Int) -> Contract? {
        let context = PersistenceController.shared.container.viewContext
        var contract: Contract?
        context.performAndWait {
            contract = get(id: id, for: context)
        }
        return contract
    }
    
    public static func saveAvatar(id: Int, image: Data) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            contract?.avatar = image
            PersistenceController.save(for: context, detailsForLogging: "Contract save avatar")
        }
    }
    
    public static func updateOnlineStatus(id: Int, isOnline: Bool) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            contract?.isOnline = isOnline
            PersistenceController.save(for: context, detailsForLogging: "Contract save online status")
        }
    }
    
    public static func updateOnlineStatusFromList(_ onlineIds: [Int]) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let fetchRequest = Contract.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "archive == NO")
            guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "Contract fetch by archive == NO for updating online status") else {
                return
            }
            for contract in fetchedResults {
                contract.isOnline = onlineIds.contains(Int(contract.id))
            }
            PersistenceController.save(for: context, detailsForLogging: "Contract save online status")
        }
    }
    
    public static func updateLastAndFirstFetchedMessage(id: Int) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            guard let contract = get(id: id, for: context) else {
                return
            }
            contract.lastFetchedMessage = Message.getLastMessageForContract(for: contract, for: context)
            contract.firstFetchedMessage = Message.getFirstMessageForContract(for: contract, for: context)
            PersistenceController.save(for: context, detailsForLogging: "Contract save lastFetchedMessage")
        }
    }
    
    public static func updateLastReadMessageIdByPatient(id: Int, lastReadMessageIdByPatient: Int) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            contract?.lastReadMessageIdByPatient = Int64(lastReadMessageIdByPatient)
            PersistenceController.save(for: context, detailsForLogging: "Contract save lastReadMessageIdByPatient")
        }
    }
    
    public static func updateContractNotes(id: Int, notes: String) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            contract?.comments = notes
            PersistenceController.save(for: context, detailsForLogging: "Contract save updateContractNotes")
        }
    }
}
