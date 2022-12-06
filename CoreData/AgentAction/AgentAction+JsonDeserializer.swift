//
//  AgentAction+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension AgentAction {
    public struct JsonDecoder: Decodable {
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
        
        public init(from decoder: Decoder) throws {
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
    
    private static func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> AgentAction {
        let agentAction = get(name: data.name, contract: contract, for: context) ?? AgentAction(context: context)
        
        agentAction.name = data.name
        agentAction.link = data.link
        agentAction.typeString = data.type
        agentAction.apiLink = data.api_link
        agentAction.isSetup = data.is_setup
        agentAction.contract = contract
        
        return agentAction
    }
    
    public static func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [AgentAction] {
        
        // Store got AgentActions to check if some contractes deleted later
        var validNames = [String]()
        var agentActions = [AgentAction]()
        
        for agentActionData in data {
            let agentAction = saveFromJson(agentActionData, contract: contract, for: context)
            
            agentActions.append(agentAction)
            validNames.append(agentActionData.name)
        }
        
        if !validNames.isEmpty {
            cleanRemoved(validNames, contract: contract, for: context)
        }
        
        return agentActions
    }
}
