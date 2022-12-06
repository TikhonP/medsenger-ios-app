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
    public class func get(id: Int) -> Contract? {
        let context = PersistenceController.shared.container.viewContext
        var contract: Contract?
        context.performAndWait {
            contract = get(id: id, for: context)
        }
        return contract
    }
    
    public class func saveAvatar(id: Int, image: Data) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            contract?.avatar = image
            PersistenceController.save(for: context, detailsForLogging: "Contract save avatar")
        }
    }
    
    public class func updateOnlineStatus(id: Int, isOnline: Bool) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            contract?.isOnline = isOnline
            PersistenceController.save(for: context, detailsForLogging: "Contract save online status")
        }
    }
    
    public class func updateOnlineStatusFromList(_ onlineIds: [Int]) {
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
    
    public class func updateLastFetchedMessage(id: Int) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            guard let contract = get(id: id, for: context) else {
                return
            }
            contract.lastFetchedMessage = Message.getLastMessageForContract(for: contract, for: context)
            PersistenceController.save(for: context, detailsForLogging: "Contract save lastFetchedMessage")
        }
    }
    
    public class func updateLastReadMessageIdByPatient(id: Int, lastReadMessageIdByPatient: Int) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            contract?.lastReadMessageIdByPatient = Int64(lastReadMessageIdByPatient)
            PersistenceController.save(for: context, detailsForLogging: "Contract save lastReadMessageIdByPatient")
        }
    }
    
    public class func clearAllContracts() {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Contract")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try PersistenceController.shared.container.persistentStoreCoordinator.execute(deleteRequest, with: context)
                PersistenceController.save(for: context, detailsForLogging: "Contract delete all")
            } catch {
                Contract.logger.error("Core Data failed to cleanup contracts: \(error.localizedDescription)")
            }
        }
    }
}
