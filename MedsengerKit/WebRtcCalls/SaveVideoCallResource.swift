//
//  SaveVideoCallResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 28.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct SaveVideoCallResource: APIResource {
    let contractId: Int
    let talkStartTime: Date
    let callStartTime: Date
    let callEndTime: Date
    let state: CallState
    let dismissCall: Bool
    
    typealias ModelType = EmptyModel
    
    var methodPath = "/protocol/video"
    
    var options: APIResourceOptions {
        APIResourceOptions(
            params: [
                URLQueryItem(name: "CONTRACT", value: "\(contractId)"),
                URLQueryItem(name: "TALK_START_TIME", value: "\(talkStartTime.timeIntervalSince1970)"),
                URLQueryItem(name: "CALL_START_TIME", value: "\(callStartTime.timeIntervalSince1970)"),
                URLQueryItem(name: "CALL_END_TIME", value: "\(callEndTime.timeIntervalSince1970)"),
                URLQueryItem(name: "STATE", value: state.rawValue),
                URLQueryItem(name: "DISMISS_CALL", value: "\(dismissCall)"),
            ]
        )
    }
}
