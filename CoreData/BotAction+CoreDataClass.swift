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
    private class func get(name: String, contract: Contract, for context: NSManagedObjectContext) -> BotAction? {
        let fetchRequest = BotAction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "BotAction get by name and contract")
        return fetchedResults?.first
    }
    
    /// Clean bot actions that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validNames: The bot actions Names that exists in JSON from Medsenger
    ///   - context: Core Data context
    ///   - contract: UserDoctorContract contract for data filtering
    private class func cleanRemoved(validNames: [String], contract: Contract, context: NSManagedObjectContext) {
        let fetchRequest = BotAction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "BotAction fetch by contract for remove") else {
            return
        }
        for botAction in fetchedResults {
            if let name = botAction.name, !validNames.contains(name) {
                context.delete(botAction)
            }
        }
    }
}

extension BotAction {
    struct JsonDecoder: Decodable {
        let link: URL
        let name: String
        let type: String?
        let api_link: URL
        let is_setup: Bool
        
        enum CodingKeys: String, CodingKey {
            case apiLink = "api_link"
            case isSetup = "is_setup"
            case link, name, type
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.link = try values.decode(URL.self, forKey: .link)
            self.name = try values.decode(String.self, forKey: .name)
            self.api_link = try values.decode(URL.self, forKey: .apiLink)
            self.is_setup = try values.decode(Bool.self, forKey: .isSetup)
            
            if values.contains(.type) {
                self.type = try values.decode(String.self, forKey: .type)
            } else {
                self.type = nil
            }
        }
    }
    
    class func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> BotAction {
        let botAction = get(name: data.name, contract: contract, for: context) ?? BotAction(context: context)
        
        botAction.name = data.name
        botAction.link = data.link
        botAction.type = data.type
        botAction.apiLink = data.api_link
        botAction.isSetup = data.is_setup
        botAction.contract = contract
        
        return botAction
    }
    
    class func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [BotAction] {
        
        // Store got AgentActions to check if some contractes deleted later
        var gotNames = [String]()
        var botActions = [BotAction]()
        
        for botActionData in data {
            let botAction = saveFromJson(botActionData, contract: contract, for: context)
            
            gotNames.append(botActionData.name)
            botActions.append(botAction)
        }
        
        if !gotNames.isEmpty {
            cleanRemoved(validNames: gotNames, contract: contract, context: context)
        }
        
        return botActions
    }
}
