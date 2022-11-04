//
//  Agent.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 01.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension Agent {
    private static func getOrCreate(medsengerId: Int, context: NSManagedObjectContext) -> Agent {
        do {
            let fetchRequest = Agent.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "medsengerId == %ld", medsengerId)
            let fetchedResults = try context.fetch(fetchRequest)
            if let agent = fetchedResults.first {
                return agent
            }
            return Agent(context: context)
        }
        catch {
            print("Fetch core data task failed: ", error)
            return Agent(context: context)
        }
    }
    
    class func save(agent: AgentResponse, context: NSManagedObjectContext) -> Agent {
        let agentModel = getOrCreate(medsengerId: agent.id, context: context)
        agentModel.medsengerId = Int64(agent.id)
        agentModel.caption = agent.description
        agentModel.name = agent.name
        agentModel.openSettingsInBlank = agent.open_settings_in_blank
        return agentModel
    }
}
