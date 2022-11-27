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
    case authSuccess = "AUTH_SUCCESS"
    case notAuthorized = "ERR_NOT_AUTHORIZED"
    case onlineList = "CURRENT_ONLINE_LIST"
    case userOnline = "USER_ONLINE"
    case userOffline = "USER_OFFLINE"
    case ice = "ICE"
    case invalidIce = "INVALID_ICE"
    case invalidStream = "INVALID_STREAM"
    case sdp = "SDP"
    case call = "CALL"
    case callContinued = "CALL_CONTINUED"
    case answered = "ANSWERED"
    case answeredFromAnotherDevice = "ANSWERED_FROM_ANOTHER_DEVICE"
    case hangUp = "HANG_UP"
    case errOffline = "ERR_OFFLINE"
    case errConnection = "ERR_CONNECTION"
    case errConnectionServer = "ERR_CONNECTION_SERVER"
    case newMessage, allRead, updateInterface
    
    static func getWebsocketResponse(_ status: Self) -> any WebsocketResponse {
        switch status {
        case .notAuthorized:
            return NotAuthorizedWebsocketResponse()
        case .authSuccess:
            return AuthSuccessWebsocketResponse()
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
        case .ice:
            return IceWebsocketResponse()
        case .invalidIce:
            return InvalidIceWebsocketResponse()
        case .invalidStream:
            return InvalidStreamWebsocketResponse()
        case .sdp:
            return SdpWebsocketResponse()
        case .call:
            return CallWebsocketResponse()
        case .callContinued:
            return CallContinuedWebsocketResponse()
        case .answered:
            return AnsweredWebsocketResponse()
        case .answeredFromAnotherDevice:
            return AnsweredFromAnotherDeviceWebsocketResponse()
        case .hangUp:
            return HangUpWebsocketResponse()
        case .errOffline:
            return ErrorOfflineWebsocketResponse()
        case .errConnection:
            return ErrorConnectionWebsocketResponse()
        case .errConnectionServer:
            return ErrorConnectionServerWebsocketResponse()
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
        print("WebsocketResponse: NotAuthorizedWebsocketResponse")
        // FIXME: !!!
    }
}

struct AuthSuccessWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: AuthSuccessWebsocketResponse")
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
        print("WebsocketResponse: AllReadWebsocketResponse: \(data)")
    }
}

struct UserOnlineWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {
        let contract: Int
    }
    
    func processResponse(_ data: Model) {
        print("WebsocketResponse: UserOnlineWebsocketResponse: \(data)")
    }
}

struct UserOfflineWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {
        let contract: Int
    }
    
    func processResponse(_ data: Model) {
        print("WebsocketResponse: UserOfflineWebsocketResponse: \(data)")
    }
}

struct CallWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: CallWebsocketResponse")
    }
}

struct CallContinuedWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: CallContinuedWebsocketResponse")
    }
}

struct ErrorOfflineWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: ErrorOfflineWebsocketResponse")
    }
}

struct HangUpWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: HangUpWebsocketResponse")
    }
}

struct AnsweredWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: AnsweredWebsocketResponse")
    }
}

struct AnsweredFromAnotherDeviceWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: AnsweredFromAnotherDeviceWebsocketResponse")
    }
}

struct ErrorConnectionWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: AnsweredFromAnotherDeviceWebsocketResponse")
    }
}

struct ErrorConnectionServerWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: ErrorConnectionServerWebsocketResponse")
    }
}

struct SdpWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {
        let contract: Int
        let sdp: SessionDescription
    }
    
    func processResponse(_ data: Model) {
        print("WebsocketResponse: ErrorConnectionServerWebsocketResponse")
    }
}

struct IceWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {
        let contract: Int
        let ice: IceCandidate
    }
    
    func processResponse(_ data: Model) {
        
    }
}

struct InvalidIceWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: InvalidIceWebsocketResponse")
    }
}

struct InvalidStreamWebsocketResponse: WebsocketResponse {
    struct Model: Decodable {}
    
    func processResponse(_: Model) {
        print("WebsocketResponse: InvalidStreamWebsocketResponse")
    }
}
