//
//  AgentAction+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension AgentAction {
    public enum AgentActionType: String {
        case url, action, `default`
    }
    
    public var type: AgentActionType {
        guard let typeString = typeString else {
            return AgentActionType.default
        }
        return AgentActionType(rawValue: typeString) ?? .default
    }
    
    public var modalLink: URL? {
        guard let apiLink = apiLink else { return nil }
        guard var components = URLComponents(url: apiLink, resolvingAgainstBaseURL: false) else {
            return nil
        }
        let apiTokenQueryItem = URLQueryItem(name: "api_token", value: KeyChain.apiToken)
        if var queryItems = components.queryItems {
            queryItems.append(apiTokenQueryItem)
            components.queryItems = queryItems
        } else {
            components.queryItems = [apiTokenQueryItem]
        }
        return components.url
    }
}
