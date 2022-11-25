//
//  AgentTask+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(AgentTask)
public class AgentTask: NSManagedObject {
    private class func get(id: Int, for context: NSManagedObjectContext) -> AgentTask? {
        let fetchRequest = AgentTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "AgentTask get by id")
        return fetchedResults?.first
    }
}

extension AgentTask {
    struct JsonDecoder: Decodable {
        let id: Int
        let action_link: URL
        let api_action_link: URL
        let agent_name: String
        let number: Int
        let target_number: Int
        let is_important: Bool
        let is_done: Bool
        let date: Date
        let done: Date?
        let text: String
        let available: Int
        let agent_id: Int
    }
    
    /// Clean agent tasks that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validAgentActionsNames: The agent tasks medsenger ids that exists in JSON from Medsenger
    ///   - context: Core Data context
    ///   - contract: UserDoctorContract contract for data filtering
    private class func cleanRemoved(validIds: [Int], contract: Contract, for context: NSManagedObjectContext) {
        let fetchRequest = AgentTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "AgentTask fetch by contract for removing") else {
            return
        }
        for agentTask in fetchedResults {
            if validIds.contains(Int(agentTask.id)) {
                context.delete(agentTask)
            }
        }
    }
    
    class func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> AgentTask {
        let agentTask = get(id: data.id, for: context) ?? AgentTask(context: context)
        
        agentTask.id = Int64(data.id)
        agentTask.actionLink = data.action_link
        agentTask.apiActionLink = data.api_action_link
        agentTask.agentName = data.agent_name
        agentTask.number = Int64(data.number)
        agentTask.targetNumber = Int64(data.target_number)
        agentTask.isImportant = data.is_important
        agentTask.isDone = data.is_done
        agentTask.date = data.date
        agentTask.done = data.done
        agentTask.text = data.text
        agentTask.available = Int64(data.available)
        agentTask.contract = contract
        
        return agentTask
    }
    
    class func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [AgentTask] {
        
        // Store got AgentActions to check if some contractes deleted later
        var validIds = [Int]()
        var agentTasks = [AgentTask]()
        
        for agentTaskData in data {
            let agentTask = saveFromJson(agentTaskData, contract: contract, for: context)
            Agent.addToAgentTasks(value: agentTask, agentID: agentTaskData.id, for: context)
            validIds.append(agentTaskData.id)
            agentTasks.append(agentTask)
        }
        
        if !validIds.isEmpty {
            cleanRemoved(validIds: validIds, contract: contract, for: context)
        }
        
        return agentTasks
    }
}
