//
//  Agent+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(Agent)
public class Agent: NSManagedObject {
    private class func get(id: Int, for context: NSManagedObjectContext) -> Agent? {
        let fetchRequest = Agent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        fetchRequest.fetchLimit = 1
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "Agent get by id")
        if let agent = fetchedResults?.first {
            return agent
        }
        return nil
    }
    
    class func addToAgentTasks(value: AgentTask, agentID: Int, for context: NSManagedObjectContext) {
        guard let agent = get(id: agentID, for: context) else { return }
        if let isExist = agent.agentTasks?.contains(value), !isExist {
            agent.addToAgentTasks(value)
        }
    }
}

extension Agent {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var wrappedDescription: String {
        agentDescription ?? "Unknown description"
    }
}

extension Agent {
    struct JsonDecoderRequestAsPatient: Decodable {
        let id: Int
        let name: String
        let description: String
        let open_settings_in_blank: Bool
    }
    
    class func saveFromJson(_ data: JsonDecoderRequestAsPatient, contract: Contract, for context: NSManagedObjectContext) {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.agentDescription = data.description
        agent.name = data.name
//        agent.isDevice = false
        contract.addToAgents(agent)
    }
    
    class func saveFromJson(_ data: [JsonDecoderRequestAsPatient], contract: Contract, for context: NSManagedObjectContext) {
        for agentData in data {
            saveFromJson(agentData, contract: contract, for: context)
        }
    }
}

extension Agent {
    struct JsonDecoderRequestAsDoctor: Decodable {
        let id: Int
        let name: String
        let description: String
        let open_settings_in_blank: Bool
        let settings_link: URL
    }
    
    class func saveFromJson(_ data: JsonDecoderRequestAsDoctor, contract: Contract, for context: NSManagedObjectContext) {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.agentDescription = data.description
        agent.name = data.name
//        agent.isDevice = false
        contract.addToAgents(agent)
    }
    
    class func saveFromJson(_ data: [JsonDecoderRequestAsDoctor], contract: Contract, for context: NSManagedObjectContext) {
        for agentData in data {
            saveFromJson(agentData, contract: contract, for: context)
        }
    }
}

// MARK: - Deserialize from `agents` from clinic in contract request as Doctor

extension Agent {
    struct JsonDecoderFromClinicAsAgent: Decodable {
        let id: Int
        let name: String
        let description: String
        let is_enabled: Bool
    }
    
    class func saveFromJson(_ data: JsonDecoderFromClinicAsAgent, clinic: Clinic, contract: Contract, for context: NSManagedObjectContext) {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.agentDescription = data.description
        agent.name = data.name
        agent.isDevice = false
        agent.addToClinics(clinic)
        if data.is_enabled {
            agent.addToEnabledContracts(contract)
        } else {
            agent.removeFromEnabledContracts(contract)
        }
    }
    
    class func saveFromJson(_ data: [JsonDecoderFromClinicAsAgent], clinic: Clinic, contract: Contract, for context: NSManagedObjectContext) {
        for agentData in data {
            saveFromJson(agentData, clinic: clinic, contract: contract, for: context)
        }
    }
}

// MARK: - Deserialize from `devices` from clinic in contract request as Doctor

extension Agent {
    struct JsonDecoderFromClinicAsDevice: Decodable {
        let id: Int
        let name: String
        let description: String
        let is_enabled: Bool
    }
    
    private class func saveFromJson(_ data: JsonDecoderFromClinicAsDevice, clinic: Clinic, contract: Contract, for context: NSManagedObjectContext) {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.name = data.name
        agent.agentDescription = data.description
        agent.isDevice = true
        agent.addToClinics(clinic)
        if data.is_enabled {
            agent.addToEnabledContracts(contract)
        } else {
            agent.removeFromEnabledContracts(contract)
        }
    }
    
    class func saveFromJson(_ data: [JsonDecoderFromClinicAsDevice], clinic: Clinic, contract: Contract, for context: NSManagedObjectContext) {
        for clinicDeviceData in data {
            saveFromJson(clinicDeviceData, clinic: clinic, contract: contract, for: context)
        }
    }
}
