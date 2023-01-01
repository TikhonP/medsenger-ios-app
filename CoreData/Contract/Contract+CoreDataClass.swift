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
    
    public static func saveAvatar(id: Int, image: Data, type: AvatarType = .default) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let contract = try get(id: id, for: moc)
            switch type {
            case .default:
                contract.avatar = image
            case .doctor:
                contract.doctorAvatar = image
            case .patient:
                contract.patientAvatar = image
            }
            try moc.wrappedSave(detailsForLogging: "Contract save avatar")
        }
    }
    
    public static func updateOnlineStatus(id: Int, isOnline: Bool) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let contract = try get(id: id, for: moc)
            contract.isOnline = isOnline
            try moc.wrappedSave(detailsForLogging: "Contract save online status")
        }
    }
    
    public static func updateOnlineStatusFromList(_ onlineIds: [Int]) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let fetchRequest = Contract.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "archive == NO")
            let fetchedResults = try moc.wrappedFetch(fetchRequest, detailsForLogging: "Contract fetch by archive == NO for updating online status")
            for contract in fetchedResults {
                contract.isOnline = onlineIds.contains(Int(contract.id))
            }
            try moc.wrappedSave(detailsForLogging: "Contract save online status")
        }
    }
    
    public static func updateLastAndFirstFetchedMessage(id: Int) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let contract = try get(id: id, for: moc)
            let lastMessage = try Message.getLastMessageForContract(for: contract, for: moc)
            contract.lastFetchedMessage = lastMessage
            try moc.wrappedSave(detailsForLogging: "Contract save lastFetchedMessage")
        }
    }
    
    public static func updateLastReadMessageIdByPatient(id: Int, lastReadMessageIdByPatient: Int) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let contract = try get(id: id, for: moc)
            contract.lastReadMessageIdByPatient = Int64(lastReadMessageIdByPatient)
            try moc.wrappedSave(detailsForLogging: "Contract save lastReadMessageIdByPatient")
        }
    }
    
    public static func updateContractNotes(id: Int, notes: String) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let contract = try get(id: id, for: moc)
            contract.comments = notes
            try moc.wrappedSave(detailsForLogging: "Contract save updateContractNotes")
        }
    }
    
    public static func saveMessageDraft(id: Int, messageDraft: String) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let contract = try get(id: id, for: moc)
            contract.messageDraft = messageDraft
            try moc.wrappedSave(detailsForLogging: "Contract save messageDraft")
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
    internal class func cleanRemoved(validContractIds: [Int], archive: Bool, for moc: NSManagedObjectContext, isConsilium: Bool = false) throws {
        let fetchRequest = Contract.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "archive == %@ AND isConsilium == %@", NSNumber(value: archive), NSNumber(value: isConsilium))
        let fetchedResults = try moc.wrappedFetch(fetchRequest, detailsForLogging: "Contract fetch by archive for removing")
        for contract in fetchedResults {
            if !validContractIds.contains(Int(contract.id)) {
                moc.delete(contract)
            }
        }
    }
}
