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
    private var customHash: String {
        "\(available)\(String(describing: text))\(String(describing: date?.timeIntervalSince1970))\(available)"
    }
    
    private class func get(customHash: String, contract: Contract, context: NSManagedObjectContext) -> AgentTask? {
        do {
            let fetchRequest = AgentTask.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for agentTask in fetchedResults {
                if agentTask.customHash == customHash {
                    return agentTask
                }
            }
            return nil
        } catch {
            print("Fetch `AgentTask` with hash: \(customHash) core data task failed: \(error.localizedDescription)")
            return nil
        }
    }
}

extension AgentTask {
    struct JsonDecoder: Decodable {
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
        
        var customHash: String {
            "\(available)\(String(describing: text))\(String(describing: date.timeIntervalSince1970))\(available)"
        }
    }
    
    /// Clean agent tasks that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validAgentActionsNames: The agent tasks medsenger ids that exists in JSON from Medsenger
    ///   - context: Core Data context
    ///   - contract: UserDoctorContract contract for data filtering
    private class func cleanRemoved(validCustomHash: [String], contract: Contract, context: NSManagedObjectContext) {
        do {
            let fetchRequest = AgentTask.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for agentTask in fetchedResults {
                if validCustomHash.contains(agentTask.customHash) {
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
            guard let agentTask = get(customHash: data.customHash, contract: contract, context: context) else {
                return AgentTask(context: context)
            }
            return agentTask
        }()
        
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
        var validCustomHashs = [String]()
        var agentTasks = [AgentTask]()
        
        for agentTaskData in data {
            let agentTask = saveFromJson(data: agentTaskData, contract: contract, context: context)
            
            validCustomHashs.append(agentTask.customHash)
            agentTasks.append(agentTask)
        }
        
        if !validCustomHashs.isEmpty {
            cleanRemoved(validCustomHash: validCustomHashs, contract: contract, context: context)
        }
        
        return agentTasks
    }
}
