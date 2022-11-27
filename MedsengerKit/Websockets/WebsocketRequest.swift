//
//  WebsocketRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 10.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import WebRTC

// MARK: Websocket Request protocol

enum WebsocketCommands: String, Encodable {
    case iAm = "I_AM"
    case messageUpdate = "MESSAGE_UPDATE"
    case call = "CALL"
    case sdp = "SDP"
    case ice = "ICE"
    case hangUp = "HANG_UP"
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
            modelDictionary["clientType"] = UserDefaults.userRole.rawValue
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

struct CallWebsocketRequest: WebsocketRequest {
    let contractId: Int
    
    struct Model: WebsocketModel {
        var mType = WebsocketCommands.call
        let contract: Int
    }
    
    var model: Model { Model(contract: contractId) }
}

struct SdpWebsocketRequest: WebsocketRequest {
    let contractId: Int
    let rtcSdp: RTCSessionDescription
    
    struct Model: WebsocketModel {
        var mType = WebsocketCommands.sdp
        let contract: Int
        let sdp: SessionDescription
    }
    
    var model: Model { Model(
        contract: contractId,
        sdp: SessionDescription(from: rtcSdp)
    ) }
}

struct IceWebsocketRequest: WebsocketRequest {
    let contractId: Int
    let rtcIceCandidate: RTCIceCandidate
    
    struct Model: WebsocketModel {
        var mType = WebsocketCommands.ice
        let contract: Int
        let ice: IceCandidate
    }
    
    var model: Model { Model(
        contract: contractId,
        ice: IceCandidate(from: rtcIceCandidate)
    ) }
}

struct HangUpWebsocketRequest: WebsocketRequest {
    let contractId: Int
    
    struct Model: WebsocketModel {
        var mType = WebsocketCommands.hangUp
        let contract: Int
    }
    
    var model: Model { Model(contract: contractId) }
}
