//
//  AgentAction+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(AgentAction)
public class AgentAction: NSManagedObject {
    enum AgentActionType: String {
        case url, action, `default`
    }
    
    var type: AgentActionType {
        guard let typeString = typeString else {
            return AgentActionType.default
        }
        return AgentActionType(rawValue: typeString) ?? .default
    }
    
    var modalLink: URL? {
        guard let apiLink = apiLink else { return nil }
        guard var components = URLComponents(url: apiLink, resolvingAgainstBaseURL: false) else {
            return nil
        }
        let apiTokenQueryItem = URLQueryItem(name: "api_token", value: KeyСhain.apiToken)
        if var queryItems = components.queryItems {
            queryItems.append(apiTokenQueryItem)
            components.queryItems = queryItems
        } else {
            components.queryItems = [apiTokenQueryItem]
        }
        return components.url
    }
    
    private class func get(name: String, contract: Contract, context: NSManagedObjectContext) -> AgentAction? {
        do {
            let fetchRequest = AgentAction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
            let fetchedResults = try context.fetch(fetchRequest)
            if let agentAction = fetchedResults.first {
                return agentAction
            }
            return nil
        } catch {
            print("Get `AgentAction` with name: \(name): core data failed: \(error.localizedDescription)")
            return nil
        }
    }
}

extension AgentAction {
    struct JsonDecoder: Decodable {
        let link: URL
        let name: String
        let type: String
        let api_link: URL
        let is_setup: Bool
    }
    
    private class func saveFromJson(data: JsonDecoder, contract: Contract, context: NSManagedObjectContext) -> AgentAction {
        let agentAction = {
            guard let agentAction = get(name: data.name, contract: contract, context: context) else {
                return AgentAction(context: context)
            }
            return agentAction
        }()
        
        agentAction.name = data.name
        agentAction.link = data.link
        agentAction.typeString = data.type
        agentAction.apiLink = data.api_link
        agentAction.isSetup = data.is_setup
        
        PersistenceController.save(context: context)
        
        return agentAction
    }
    
    /// Clean agent actions that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validAgentActionsNames: The agent actions Names that exists in JSON from Medsenger
    ///   - contract: UserDoctorContract contract for data filtering
    ///   - context: Core Data context
    private class func cleanRemoved(validNames: [String], contract: Contract, context: NSManagedObjectContext) {
        do {
            let fetchRequest = AgentAction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for agentAction in fetchedResults {
                if let name = agentAction.name, validNames.contains(name) {
                    context.delete(agentAction)
                    PersistenceController.save(context: context)
                }
            }
        } catch {
            print("Fetch `AgentAction`: core data failed: \(error.localizedDescription)")
        }
    }
    
    class func saveFromJson(data: [JsonDecoder], contract: Contract, context: NSManagedObjectContext) -> [AgentAction] {
        
        // Store got AgentActions to check if some contractes deleted later
        var validNames = [String]()
        var agentActions = [AgentAction]()
        
        for agentActionData in data {
            let agentAction = saveFromJson(data: agentActionData, contract: contract, context: context)
            
            agentActions.append(agentAction)
            validNames.append(agentActionData.name)
        }
        
//        if !validNames.isEmpty {
//            cleanRemoved(validNames: validNames, contract: contract, context: context)
//        }
        
        return agentActions
    }
}
