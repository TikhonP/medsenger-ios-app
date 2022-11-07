//
//  BotAction.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension BotAction {
    private static func getOrCreate(name: String, context: NSManagedObjectContext, contract: UserDoctorContract) -> BotAction {
        do {
            let fetchRequest = BotAction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
            let fetchedResults = try context.fetch(fetchRequest)
            if let botAction = fetchedResults.first {
                return botAction
            }
            return BotAction(context: context)
        }
        catch {
            print("Fetch core data task failed: ", error.localizedDescription)
            return BotAction(context: context)
        }
    }
    
    /// Clean bot actions that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validAgentActionsNames: The bot actions Names that exists in JSON from Medsenger
    ///   - context: Core Data context
    ///   - contract: UserDoctorContract contract for data filtering
    private static func cleanRemoved(validBotActionsNames: [String], context: NSManagedObjectContext, contract: UserDoctorContract) {
        do {
            let fetchRequest = BotAction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for botAction in fetchedResults {
                if let name = botAction.name, !validBotActionsNames.contains(name) {
                    context.delete(botAction)
                }
            }
        }
        catch {
            print("Fetch core data task failed: ", error.localizedDescription)
        }
    }
    
    class func save(botActions: [BotActionResponse], contract: UserDoctorContract, context: NSManagedObjectContext) {
        
        // Store got AgentActions to check if some contractes deleted later
        var gotBotActionsIds = [String]()
        
        for botAction in botActions {
            gotBotActionsIds.append(botAction.name)
            let agentBotModel = getOrCreate(name: botAction.name, context: context, contract: contract)
            agentBotModel.name = botAction.name
            agentBotModel.link = botAction.link
            agentBotModel.type = botAction.type
            agentBotModel.apiLink = botAction.api_link
            agentBotModel.isSetup = botAction.is_setup
            agentBotModel.contract = contract
        }
        
        if !gotBotActionsIds.isEmpty {
            cleanRemoved(validBotActionsNames: gotBotActionsIds, context: context, contract: contract)
        }
        
        PersistenceController.save(context: context)
    }
}
