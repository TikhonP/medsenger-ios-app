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
    private class func get(id: Int, context: NSManagedObjectContext) -> Agent? {
        do {
            let fetchRequest = Agent.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            let fetchedResults = try context.fetch(fetchRequest)
            if let agent = fetchedResults.first {
                return agent
            }
            return nil
        }
        catch {
            print("Get `Agent` with id: \(id) core data failed: ", error.localizedDescription)
            return nil
        }
    }
    
    class func addToAgentTasks(value: AgentTask, agentID: Int, context: NSManagedObjectContext) {
        guard let agent = get(id: agentID, context: context) else { return }
        if let isExist = agent.agentTasks?.contains(value), !isExist {
            agent.addToAgentTasks(value)
            PersistenceController.save(context: context)
        }
    }
}

extension Agent {
    struct JsonDecoder: Decodable {
        let id: Int
        let name: String
        let description: String
        let open_settings_in_blank: Bool
    }
    
    private class func saveFromJson(data: JsonDecoder, context: NSManagedObjectContext) -> Agent {
        let agent = {
            guard let agent = get(id: data.id, context: context) else {
                return Agent(context: context)
            }
            return agent
        }()
        
        agent.id = Int64(data.id)
        agent.caption = data.description
        agent.name = data.name
        agent.openSettingsInBlank = data.open_settings_in_blank
        
        PersistenceController.save(context: context)
        
        return agent
    }
    
    class func saveFromJson(data: [JsonDecoder], context: NSManagedObjectContext) -> [Agent] {
        var agents = [Agent]()
        
        for agentData in data {
            let agent = saveFromJson(data: agentData, context: context)
            agents.append(agent)
        }
        
        return agents
    }
}
