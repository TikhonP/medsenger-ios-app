//
//  AgentAction.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

//extension AgentAction {
//    private static func getOrCreate(name: String, context: NSManagedObjectContext, contract: UserDoctorContract) -> AgentAction {
//        do {
//            let fetchRequest = AgentAction.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
//            let fetchedResults = try context.fetch(fetchRequest)
//            if let agentAction = fetchedResults.first {
//                return agentAction
//            }
//            return AgentAction(context: context)
//        }
//        catch {
//            print("Fetch core data task failed: ", error.localizedDescription)
//            return AgentAction(context: context)
//        }
//    }
//    
//    /// Clean agent actions that was not got in incoming JSON from Medsenger
//    /// - Parameters:
//    ///   - validAgentActionsNames: The agent actions Names that exists in JSON from Medsenger
//    ///   - context: Core Data context
//    ///   - contract: UserDoctorContract contract for data filtering
//    private static func cleanRemoved(validAgentActionsNames: [String], context: NSManagedObjectContext, contract: UserDoctorContract) {
//        do {
//            let fetchRequest = AgentAction.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
//            let fetchedResults = try context.fetch(fetchRequest)
//            for agentAction in fetchedResults {
//                if let name = agentAction.name, validAgentActionsNames.contains(name) {
//                    context.delete(agentAction)
//                }
//            }
//        }
//        catch {
//            print("Fetch core data task failed: ", error.localizedDescription)
//        }
//    }
//    
//    class func save(agentActions: [AgentActionResponse], contract: UserDoctorContract, context: NSManagedObjectContext) {
//        
//        // Store got AgentActions to check if some contractes deleted later
//        var gotAgentActionsIds = [String]()
//        
//        for agentAction in agentActions {
//            gotAgentActionsIds.append(agentAction.name)
//            let agentActionModel = getOrCreate(name: agentAction.name, context: context, contract: contract)
//            agentActionModel.name = agentAction.name
//            agentActionModel.link = agentAction.link
//            agentActionModel.type = agentAction.type
//            agentActionModel.apiLink = agentAction.api_link
//            agentActionModel.isSetup = agentAction.is_setup
//            agentActionModel.contract = contract
//        }
//        
//        if !gotAgentActionsIds.isEmpty {
//            cleanRemoved(validAgentActionsNames: gotAgentActionsIds, context: context, contract: contract)
//        }
//        
//        PersistenceController.save(context: context)
//    }
//}
