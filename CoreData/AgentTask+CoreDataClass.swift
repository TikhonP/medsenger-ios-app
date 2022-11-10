//
//  AgentTask+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(AgentTask)
public class AgentTask: NSManagedObject {
    private class func get(id: Int, contract: Contract, context: NSManagedObjectContext) -> AgentTask? {
        do {
            let fetchRequest = AgentTask.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = %ld && contract = %@", id, contract)
            let fetchedResults = try context.fetch(fetchRequest)
            if let agentTask = fetchedResults.first {
                return agentTask
            }
            return nil
        } catch {
            print("Fetch `AgentTask` with id: \(id) core data task failed: \(error.localizedDescription)")
            return nil
        }
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
    private class func cleanRemoved(validIds: [Int], contract: Contract, context: NSManagedObjectContext) {
        do {
            let fetchRequest = AgentTask.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for agentTask in fetchedResults {
                if validIds.contains(Int(agentTask.id)) {
                    context.delete(agentTask)
                    PersistenceController.save(context: context)
                }
            }
        } catch {
            print("Fetch `AgentTask` core data task failed: \(error.localizedDescription)")
        }
    }
    
    class func saveFromJson(data: JsonDecoder, contract: Contract, context: NSManagedObjectContext) -> AgentTask {
        let agentTask = {
            guard let agentTask = get(id: data.id, contract: contract, context: context) else {
                return AgentTask(context: context)
            }
            return agentTask
        }()
        
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
        
        PersistenceController.save(context: context)
        
        return agentTask
    }
    
    class func saveFromJson(data: [JsonDecoder], contract: Contract, context: NSManagedObjectContext) -> [AgentTask] {
        
        // Store got AgentActions to check if some contractes deleted later
        var validIds = [Int]()
        var agentTasks = [AgentTask]()
        
        for agentTaskData in data {
            let agentTask = saveFromJson(data: agentTaskData, contract: contract, context: context)
            Agent.addToAgentTasks(value: agentTask, agentID: agentTaskData.id, context: context)
            validIds.append(agentTaskData.id)
            agentTasks.append(agentTask)
        }
        
        if !validIds.isEmpty {
            cleanRemoved(validIds: validIds, contract: contract, context: context)
        }
        
        return agentTasks
    }
}
