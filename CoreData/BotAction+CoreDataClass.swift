//
//  BotAction+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(BotAction)
public class BotAction: NSManagedObject {
    private class func get(name: String, contract: Contract, context: NSManagedObjectContext) -> BotAction? {
        do {
            let fetchRequest = BotAction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
            let fetchedResults = try context.fetch(fetchRequest)
            if let botAction = fetchedResults.first {
                return botAction
            }
            return nil
        } catch {
            print("Fetch `BotAction` with name: \(name) core data failed: ", error.localizedDescription)
            return nil
        }
    }
}

extension BotAction {
    struct JsonDecoder: Decodable {
        let link: URL
        let name: String
        let type: String
        let api_link: URL
        let is_setup: Bool
    }
    
    /// Clean bot actions that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validNames: The bot actions Names that exists in JSON from Medsenger
    ///   - context: Core Data context
    ///   - contract: UserDoctorContract contract for data filtering
    private class func cleanRemoved(validNames: [String], contract: Contract, context: NSManagedObjectContext) {
        do {
            let fetchRequest = BotAction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for botAction in fetchedResults {
                if let name = botAction.name, !validNames.contains(name) {
                    context.delete(botAction)
                    PersistenceController.save(context: context)
                }
            }
        } catch {
            print("Fetch core data task failed: ", error.localizedDescription)
        }
    }
    
    class func saveFromJson(data: JsonDecoder, contract: Contract, context: NSManagedObjectContext) -> BotAction {
        let botAction = {
            guard let botAction = get(name: data.name, contract: contract, context: context) else {
                return BotAction(context: context)
            }
            return botAction
        }()
        
        botAction.name = data.name
        botAction.link = data.link
        botAction.type = data.type
        botAction.apiLink = data.api_link
        botAction.isSetup = data.is_setup
        
        PersistenceController.save(context: context)
        
        return botAction
    }
    
    class func saveFromJson(data: [JsonDecoder], contract: Contract, context: NSManagedObjectContext) -> [BotAction] {
        
        // Store got AgentActions to check if some contractes deleted later
        var gotNames = [String]()
        var botActions = [BotAction]()
        
        for botActionData in data {
            let botAction = saveFromJson(data: botActionData, contract: contract, context: context)
            
            gotNames.append(botActionData.name)
            botActions.append(botAction)
        }
        
//        if !gotNames.isEmpty {
//            cleanRemoved(validNames: gotNames, contract: contract, context: context)
//        }
        
        return botActions
    }
}
