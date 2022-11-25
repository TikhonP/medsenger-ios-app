//
//  WebsocketResponse.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 10.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

// MARK: Websocket Request protocol

enum WebsocketResponseStatus: String, Decodable {
    case notAuthorized = "ERR_NOT_AUTHORIZED"
    case authSuccess = "AUTH_SUCCESS"
    case onlineList = "CURRENT_ONLINE_LIST"
    case userOnline = "USER_ONLINE"
    case userOffline = "USER_OFFLINE"
    case newMessage, allRead, updateInterface
    
    static func getWebsocketResponse(_ status: Self) -> any WebsocketResponse {
        switch status {
        case .notAuthorized:
            return NotAuthorizedWebsocketResponse()
        case .authSuccess:
            return authSuccessWebsocketResponse()
        case .onlineList:
            return OnlineListWebsocketResponse()
        case .newMessage:
            return NewMessageWebsocketResponse()
        case .allRead:
            return AllReadWebsocketResponse()
        case .userOnline:
            return UserOnlineWebsocketResponse()
        case .userOffline:
            return UserOfflineWebsocketResponse()
        case .updateInterface:
            return NewMessageWebsocketResponse()
        }
    }
}

struct WebsocketResponseStatusModel: Decodable {
    let mType: WebsocketResponseStatus
}

protocol WebsocketResponse {
    associatedtype ModelType: Decodable
    
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
    
    func processResponse(_ data: ModelType)
    func decode(_ string: String) -> DecodedDataReslut<ModelType>
    
    init()
}

extension WebsocketResponse {
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .secondsSince1970 }
    
    func decode(_ string: String) -> DecodedDataReslut<ModelType> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            let wrapper = try decoder.decode(ModelType.self, from: Data(string.utf8))
            return DecodedDataReslut<ModelType>.success(wrapper)
        } catch DecodingError.dataCorrupted(let context) {
            return DecodedDataReslut<ModelType>.failure(.dataCorrupted(context))
        } catch DecodingError.keyNotFound(let key, let context) {
            return DecodedDataReslut<ModelType>.failure(.keyNotFound(key, context))
        } catch DecodingError.valueNotFound(let value, let context) {
            return DecodedDataReslut<ModelType>.failure(.valueNotFound(value, context))
        } catch DecodingError.typeMismatch(let type, let context) {
            return DecodedDataReslut<ModelType>.failure(.typeMismatch(type, context))
        } catch {
            return DecodedDataReslut<ModelType>.failure(.error(error))
        }
    }
}

// MARK: - Websocket responses

struct NotAuthorizedWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("Websocket not authorized")
        // FIXME: !!!
    }
}

struct authSuccessWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("Websocket authorization success")
    }
}

struct OnlineListWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {
        let online_contracts: [Int]
    }
    
    func processResponse(_ data: Model) {
        Contract.updateOnlineStatusFromList(data.online_contracts)
    }
}

struct NewMessageWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {
        let contract_id: Int
    }
    
    func processResponse(_ data: Model) {
//        Contracts.shared.getDoctors()
        Messages.shared.fetchMessages(contractId: data.contract_id)
    }
}

struct AllReadWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {
        let contract_id: Int
        let last_read_id: Int
        let sender: String
    }
    
    func processResponse(_ data: Model) {
        print("All resd: \(data)")
    }
}

struct UserOnlineWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {
        let contract: Int
    }
    
    func processResponse(_ data: Model) {
        print("User Online: \(data)")
    }
}

struct UserOfflineWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {
        let contract: Int
    }
    
    func processResponse(_ data: Model) {
        print("User Offline: \(data)")
    }
}
