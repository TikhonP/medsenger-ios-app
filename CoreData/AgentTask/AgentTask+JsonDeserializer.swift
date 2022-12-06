//
//  AgentTask+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension AgentTask {
    public struct JsonDecoder: Decodable {
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
    
    private static func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> AgentTask {
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
    
    public static func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [AgentTask] {
        
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
            cleanRemoved(validIds, contract: contract, for: context)
        }
        
        return agentTasks
    }
}
