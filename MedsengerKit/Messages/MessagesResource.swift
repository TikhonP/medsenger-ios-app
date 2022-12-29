//
//  MessagesResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

/// Get list of messages resource
struct MessagesResource: APIResource {
    let contractId: Int
    let fromMessageId: Int?
    
    let minId: Int?
    let maxId: Int?
    
    // If true then acsending from first to last
    let desc: Bool

    let offset: Int?
    let limit: Int?
    
    typealias ModelType = Array<Message.JsonDeserializer>
    
    var methodPath: String {
        if let fromMessageId = fromMessageId {
            return "/doctors/\(contractId)/messages/\(fromMessageId)"
        } else {
            return "/doctors/\(contractId)/messages"
        }
    }
    
    var params: [URLQueryItem] {
        var params = [URLQueryItem]()
        if let minId = minId {
            params.append(URLQueryItem(name: "min_id", value: String(minId)))
        }
        if let maxId = maxId {
            params.append(URLQueryItem(name: "max_id", value: String(maxId)))
        }
        params.append(URLQueryItem(name: "desc", value: String(desc)))
        if let offset = offset {
            params.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        if let limit = limit {
            params.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        return params
    }
    
    var options: APIResourceOptions {
        APIResourceOptions(
            parseResponse: true,
            params: params,
            dateDecodingStrategy: .secondsSince1970
        )
    }
    
    internal var apiErrors: [APIResourceError<Error>] = []
}
