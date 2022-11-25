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
    struct JsonDecoderRequestAsPatient: Decodable {
        let id: Int
        let name: String
        let description: String
        let open_settings_in_blank: Bool
    }
    
    class func saveFromJson(_ data: JsonDecoderRequestAsPatient, for context: NSManagedObjectContext) -> Agent {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.caption = data.description
        agent.name = data.name
        agent.openSettingsInBlank = data.open_settings_in_blank
        
        return agent
    }
    
    class func saveFromJson(_ data: [JsonDecoderRequestAsPatient], for context: NSManagedObjectContext) -> [Agent] {
        var agents = [Agent]()
        
        for agentData in data {
            let agent = saveFromJson(agentData, for: context)
            agents.append(agent)
        }
        
        return agents
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
    
    class func saveFromJson(_ data: JsonDecoderRequestAsDoctor, for context: NSManagedObjectContext) -> Agent {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.caption = data.description
        agent.name = data.name
        agent.openSettingsInBlank = data.open_settings_in_blank
        agent.settingsLink = data.settings_link
        
        return agent
    }
    
    class func saveFromJson(_ data: [JsonDecoderRequestAsDoctor], for context: NSManagedObjectContext) -> [Agent] {
        var agents = [Agent]()
        
        for agentData in data {
            let agent = saveFromJson(agentData, for: context)
            agents.append(agent)
        }
        
        return agents
    }
}

extension Agent {
    struct JsonDecoderFromClinic: Decodable {
        let id: Int
        let name: String
        let description: String
        let is_enabled: Bool
    }
    
    class func saveFromJson(_ data: JsonDecoderFromClinic, for context: NSManagedObjectContext) -> Agent {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.caption = data.description
        agent.name = data.name
        agent.isEnabled = data.is_enabled
        
        return agent
    }
    
    class func saveFromJson(_ data: [JsonDecoderFromClinic], for context: NSManagedObjectContext) -> [Agent] {
        var agents = [Agent]()
        
        for agentData in data {
            let agent = saveFromJson(agentData, for: context)
            agents.append(agent)
        }
        
        return agents
    }
}
