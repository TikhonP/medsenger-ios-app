//
//  WebsocketRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 10.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

// MARK: Websocket Request protocol

enum WebsocketCommands: String, Encodable {
    case iAm = "I_AM"
    case messageUpdate = "MESSAGE_UPDATE"
}

protocol WebsocketModel: Encodable {
    var mType: WebsocketCommands { get }
}

extension WebsocketModel {
    var asDictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}

protocol WebsocketRequest {
    associatedtype ModelType: WebsocketModel
    
    var model: ModelType { get }
}

extension WebsocketRequest {
    var data: String? {
        do {
            var modelDictionary = model.asDictionary
            modelDictionary["clientType"] = Account.shared.role.clientsForNetworkRequest
            modelDictionary["clientToken"] = KeyСhain.apiToken
            let jsonData = try JSONSerialization.data(withJSONObject: modelDictionary)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            print("Error with encodeing to JSON data for websockets: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Websocket requests

/// Initilize connection request
struct IAmWebsocketRequest: WebsocketRequest {
    struct Model: WebsocketModel {
        var mType = WebsocketCommands.iAm
    }
    
    var model = Model()
}

struct MessageUpdateWebsocketRequest: WebsocketRequest {
    let contractId: Int
    
    struct Model: WebsocketModel {
        var mType = WebsocketCommands.messageUpdate
        let contract: Int
    }
    
    var model: Model { Model(contract: contractId) }
}
