//
//  VideoConference.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

enum VideoConferenceMessageType: String, Codable {
    case authFailed = "AUTH_FAILED"
    case authSuccess = "AUTH_SUCCESS"
    case ice = "ICE"
    case sdp = "SDP"
    case interlocutorConnected = "INTERLOCUTOR_CONNECTED"
    case interlocutorDisconnected = "INTERLOCUTOR_DISCONNECTED"
    case breakByNewConnection = "BREAK_BY_NEW_CONNECTION"
    case auth = "AUTH"
    case closeRoom = "CLOSE_ROOM"
}

struct VideoConferenceMessageWrapper<T: Codable>: Codable {
    let id: String
    let timestamp: Date
    let type: VideoConferenceMessageType
//    let params: T
    
    init(type: VideoConferenceMessageType) {
        self.id = UUID().uuidString
        self.timestamp = Date()
        self.type = type
    }
}

class VideoConference: NSObject {
    private let accessKey: String
    private let role: String
    private let room: String
    
    private var webSocket: URLSessionWebSocketTask?
    
    init(accessKey: String, role: String, room: String, webSocket: URLSessionWebSocketTask? = nil) {
        self.accessKey = accessKey
        self.role = role
        self.room = room
        self.webSocket = webSocket
    }
    
    func encode<T: Codable>(_ message: VideoConferenceMessageWrapper<T>) -> Data? {
        do {
            return try JSONEncoder().encode(message)
        } catch {
            print("VideoConference: encode failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    func sendMessage<T: Codable>(_ message: VideoConferenceMessageWrapper<T>) {
        guard let data = encode(message) else {
            return
        }
        webSocket?.send(.data(data), completionHandler: { error in
            if let error = error {
                print("VideoConference: send failed: \(error.localizedDescription)")
            }
        })
    }
}

extension VideoConference: URLSessionWebSocketDelegate {
    
}
