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
    
    private class func get(name: String, contract: Contract, for context: NSManagedObjectContext) -> AgentAction? {
        let fetchRequest = AgentAction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "AgentAction get by name and contract")
        if let agentAction = fetchedResults?.first {
            return agentAction
        }
        return nil
    }
    
    /// Clean agent actions that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validAgentActionsNames: The agent actions Names that exists in JSON from Medsenger
    ///   - contract: UserDoctorContract contract for data filtering
    ///   - context: Core Data context
    private class func cleanRemoved(validNames: [String], contract: Contract, context: NSManagedObjectContext) {
        let fetchRequest = AgentAction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "AgentAction fetch by contract for removing") else {
            return
        }
        for agentAction in fetchedResults {
            if let name = agentAction.name, !validNames.contains(name) {
                context.delete(agentAction)
            }
        }
    }
}

extension AgentAction {
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
    
    private class func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> AgentAction {
        let agentAction = get(name: data.name, contract: contract, for: context) ?? AgentAction(context: context)
        
        agentAction.name = data.name
        agentAction.link = data.link
        agentAction.typeString = data.type
        agentAction.apiLink = data.api_link
        agentAction.isSetup = data.is_setup
        agentAction.contract = contract
        
        return agentAction
    }
    
    class func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [AgentAction] {
        
        // Store got AgentActions to check if some contractes deleted later
        var validNames = [String]()
        var agentActions = [AgentAction]()
        
        for agentActionData in data {
            let agentAction = saveFromJson(agentActionData, contract: contract, for: context)
            
            agentActions.append(agentAction)
            validNames.append(agentActionData.name)
        }
        
        if !validNames.isEmpty {
            cleanRemoved(validNames: validNames, contract: contract, context: context)
        }
        
        return agentActions
    }
}
