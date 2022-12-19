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
    public enum AvatarType {
        case `default`, doctor, patient
    }
    
    public static func saveAvatar(id: Int, image: Data, type: AvatarType = .default) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            switch type {
            case .default:
                contract?.avatar = image
            case .doctor:
                contract?.doctorAvatar = image
            case .patient:
                contract?.patientAvatar = image
            }
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
    
    public static func updateLastAndFirstFetchedMessage(id: Int, updateGlobal: Bool) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            guard let contract = get(id: id, for: context) else {
                return
            }
            let lastMessage = Message.getLastMessageForContract(for: contract, for: context)
            contract.lastFetchedMessage = lastMessage
            if updateGlobal {
                contract.lastGlobalFetchedMessage = lastMessage
            }
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
    
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Contract.self)
    )
    
    /// Clean contract that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validContractIds: The contract ids that exists in JSON from Medsenger
    ///   - context: Core Data context
    internal class func cleanRemoved(validContractIds: [Int], archive: Bool, for context: NSManagedObjectContext, isConsilium: Bool = false) {
        let fetchRequest = Contract.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "archive == %@ AND isConsilium == %@", NSNumber(value: archive), NSNumber(value: isConsilium))
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
