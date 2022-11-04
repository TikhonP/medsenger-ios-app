//
//  AgentTask.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

//extension AgentTask {
//    private static func hash(agentTask: AgentTask) -> String {
//        return String(agentTask.available) + String(agentTask.text) + String(agentTask.name) + String(agentTask.date?.timeIntervalSince1970) + String(agentTask.available)
//    }
//    
//    private static func getOrCreate(medsengerId: Int, context: NSManagedObjectContext, contract: UserDoctorContract) -> AgentTask {
//        do {
//            let fetchRequest = AgentTask.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "medsengerId == %ld && contract = %@", medsengerId, contract)
//            let fetchedResults = try context.fetch(fetchRequest)
//            if let agentTask = fetchedResults.first {
//                return agentTask
//            }
//            return AgentTask(context: context)
//        }
//        catch {
//            print("Fetch core data task failed: ", error)
//            return AgentTask(context: context)
//        }
//    }
//    
//    /// Clean agent tasks that was not got in incoming JSON from Medsenger
//    /// - Parameters:
//    ///   - validAgentActionsNames: The agent tasks medsenger ids that exists in JSON from Medsenger
//    ///   - context: Core Data context
//    ///   - contract: UserDoctorContract contract for data filtering
//    private static func cleanReamoved(validAgentTasks: [AgentTaskResponse], context: NSManagedObjectContext, contract: UserDoctorContract) {
//        do {
//            let fetchRequest = AgentTask.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
//            let fetchedResults = try context.fetch(fetchRequest)
//            for agentTask in fetchedResults {
//                if validAgentTaskIds.contains(Int(agentTask.medsengerId)) {
//                    context.delete(agentTask)
//                }
//            }
//        }
//        catch {
//            print("Fetch core data task failed: ", error)
//        }
//    }
//    
//    class func saveAgentActions(agentTasks: [AgentTaskResponse], contract: UserDoctorContract) {
//        let context = PersistenceController.shared.container.viewContext
//        
//        // Store got AgentActions to check if some contractes deleted later
//        var gotAgentTasks = [AgentTaskResponse]()
//        
//        for agentTask in agentTasks {
//            gotAgentTasks.append(agentTask)
//            let agentTaskModel = getOrCreate(medsengerId: agentTask.id, context: context, contract: contract)
//            agentActionModel.name = agentAction.name
//            agentActionModel.link = agentAction.link
//            agentActionModel.type = agentAction.type
//            agentActionModel.apiLink = agentAction.api_link
//            agentActionModel.isSetup = agentAction.is_setup
//            agentActionModel.contract = contract
//        }
//        
//        if !gotAgentActionsIds.isEmpty {
//            cleanReamoved(validAgentTaskIds: gotAgentActionsIds, context: context, contract: contract)
//        }
//        
//        PersistenceController.save(context: context)
//    }
//}
