//
//  Constants.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct Constants {
    
    static let medsengerApiUrl = "https://medsenger.ru/api/client" // "http://192.168.1.24:8000/api/client"

    static let medsengerWebsocketUrl = URL(string: "wss://medsenger.ru:643")! // URL(string: "wss://192.168.1.24:643")!
    
    static let voiceMessageFileName = "voiceMessage.m4a"
    static let voiceMessageText = "Голосовое сообщение"
    
    struct MedsengerErrorStrings {
        static let incorrectToken = "Incorrect token"
        static let incorrectData = "Incorrect data"
    }
}
