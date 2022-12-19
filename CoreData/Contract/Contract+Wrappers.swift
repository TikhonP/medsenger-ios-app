//
//  Contract+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension Contract {
    public enum State: String, Decodable {
        case noMessages = "no_messages" // FIXME: !!!
        case unread = "unread"
        case waiting = "waiting"
        case warning = "warning"
        case deadlined = "deadlined"
    }
    
    public var state: State {
        guard let stateString = stateString else {
            return .noMessages
        }
        return State(rawValue: stateString) ?? .noMessages
    }
    
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var wrappedShortName: String {
        shortName ?? "Unknown name"
    }
    
    public var wrappedRole: String {
        role ?? "Unknown role"
    }
    
    public var wrappedNumber: String {
        number ?? "Unknown number"
    }
    
    public var wrappedComments: String {
        comments ?? ""
    }
    
    public var wrappedPatientName: String {
        patientName ?? "Unknown patient name"
    }
    
    public var wrappedDoctorName: String {
        doctorName ?? "Unknown doctor name"
    }
    
    public var messagesArray: [Message] {
        let set = messages as? Set<Message> ?? []
        return Array(set)
    }
    
    public var infoMaterialsArray: [InfoMaterial] {
        let set = infoMaterials as? Set<InfoMaterial> ?? []
        return Array(set)
    }
    
    public var agentActionsArray: [AgentAction] {
        let set = agentActions as? Set<AgentAction> ?? []
        return set.sorted(by: { $0.id > $1.id })
    }
    
    public var agentTasksArray: [AgentTask] {
        let set = agentTasks as? Set<AgentTask> ?? []
        return Array(set)
    }
    
    public var doctorHelpersArray: [DoctorHelper] {
        let set = doctorHelpers as? Set<DoctorHelper> ?? []
        return Array(set)
    }
    
    public var patientHelpersArray: [PatientHelper] {
        let set = patientHelpers as? Set<PatientHelper> ?? []
        return Array(set)
    }
    
    public var devices: [Agent] {
        let context = PersistenceController.shared.container.viewContext
        var result = [Agent]()
        context.performAndWait {
            let fetchRequest = Agent.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "enabledContracts CONTAINS %@ AND isDevice == YES", self)
            if let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "Contract.hasDevices") {
                result = fetchedResults
            }
        }
        return result
    }
}
