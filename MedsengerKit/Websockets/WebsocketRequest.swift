//
//  WebsocketRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 10.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import WebRTC
import os.log

// MARK: Websocket Request protocol

enum WebsocketCommands: String, Encodable {
    case iAm = "I_AM"
    case messageUpdate = "MESSAGE_UPDATE"
    case call = "CALL"
    case sdp = "SDP"
    case ice = "ICE"
    case hangUp = "HANG_UP"
    case invalidIce = "INVALID_ICE"
    case invalidStream = "INVALID_STREAM"
    case answer = "ANSWER"
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
            modelDictionary["clientToken"] = KeyChain.apiToken
            let jsonData = try JSONSerialization.data(withJSONObject: modelDictionary)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            Logger.websockets.error("Error with encodeing to JSON data for websockets: \(error.localizedDescription)")
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

struct InvalidIceWebsocketRequest: WebsocketRequest {
    let contractId: Int
    
    struct Model: WebsocketModel {
        var mType = WebsocketCommands.invalidIce
        let contract: Int
    }
    
    var model: Model { Model(contract: contractId) }
}

struct InvalidStreamWebsocketRequest: WebsocketRequest {
    let contractId: Int
    
    struct Model: WebsocketModel {
        var mType = WebsocketCommands.invalidStream
        let contract: Int
    }
    
    var model: Model { Model(contract: contractId) }
}

struct AnswerWebsocketRequest: WebsocketRequest {
    let contractId: Int
    
    struct Model: WebsocketModel {
        var mType = WebsocketCommands.answer
        let contract: Int
    }
    
    var model: Model { Model(contract: contractId) }
}
