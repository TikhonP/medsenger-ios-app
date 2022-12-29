//
//  BotAction+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension BotAction {
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
    
    private static func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> BotAction {
        let botAction = (try? get(name: data.name, contract: contract, for: context)) ?? BotAction(context: context)
        
        botAction.name = data.name
        botAction.link = data.link
        botAction.type = data.type
        botAction.apiLink = data.api_link
        botAction.isSetup = data.is_setup
        botAction.contract = contract
        
        return botAction
    }
    
    public static func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [BotAction] {
        
        // Store got AgentActions to check if some contractes deleted later
        var gotNames = [String]()
        var botActions = [BotAction]()
        
        for botActionData in data {
            let botAction = saveFromJson(botActionData, contract: contract, for: context)
            
            gotNames.append(botActionData.name)
            botActions.append(botAction)
        }
        
        if !gotNames.isEmpty {
            cleanRemoved(gotNames, contract: contract, for: context)
        }
        
        return botActions
    }
}
