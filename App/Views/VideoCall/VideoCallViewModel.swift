//
//  VideoCallViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import WebRTC
import os.log

enum CallState: String {
    case connected = "CONNECTED"
    case canceled = "CANCELED"
    case notPhoned = "NOT_PHONED"
    case dismissCall = "DISMISS_CALL"
    case disconnect = "DISCONNECT"
    case patientOffline = "PATIENT_OFFLINE"
    case hangUp = "HANG_UP"
    case stopTalk = "STOP_TALK"
    case `init` = "INIT"
}

@MainActor
final class VideoCallViewModel: ObservableObject {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: VideoCallViewModel.self)
    )
    
    let webRTCClient: WebRTCClient
    
    private let contractId: Int
    private weak var contentViewModel: ContentViewModel?
    
    private var callStartTime: Date?
    private var callEndTime: Date?
    private var talkStartTime: Date?
    private var dismissCall = false
    private var state: CallState = CallState(rawValue: "INIT")!
    
    @Published var isCaller: Bool
    @Published var rtcState: RTCIceConnectionState = .new
    @Published var answered = false
    @Published var finishingCall = false
   
    @Published var isVideoOn = true
    @Published var isAudioOn = true
    
    required init(contractId: Int, contentViewModel: ContentViewModel) {
        self.contractId = contractId
        self.webRTCClient = WebRTCClient(contractId: contractId)
        self.contentViewModel = contentViewModel
        self.isCaller = contentViewModel.isCaller
        
        self.webRTCClient.delegate = self
        Websockets.shared.callDelegate = self
    }
    
    func videoCallViewAppear() {
        callStartTime = Date()
        if let isCaller = contentViewModel?.isCaller, isCaller {
            Websockets.shared.makeCall(contractId: contractId)
        }
    }
    
    func callingViewAppear() {
        talkStartTime = Date()
    }
    
    func answer() {
        Websockets.shared.answer(contractId: contractId)
    }
    
    func dismiss() {
        state = .dismissCall
        hangUp()
        dismissCall = true
    }
    
    func hangUp() {
        Websockets.shared.hangUp(contractId: contractId)
        stopCall()
    }
    
    func toggleAudio() {
        if isAudioOn {
            webRTCClient.muteAudio()
        } else {
            webRTCClient.unmuteAudio()
        }
        isAudioOn.toggle()
    }
    
    func toggleVideo() {
        if isVideoOn {
            webRTCClient.hideVideo()
        } else {
            webRTCClient.showVideo()
        }
        isVideoOn.toggle()
    }
    
    private func stopCall() {
        callEndTime = Date()
        DispatchQueue.main.async {
            self.finishingCall = true
        }
        webRTCClient.saveVideoCall(
            contractId: contractId,
            talkStartTime: talkStartTime ?? Date(),
            callStartTime: callStartTime ?? Date(),
            callEndTime: callEndTime ?? Date(),
            state: state, dismissCall: dismissCall) {
                self.contentViewModel?.hideCall()
                DispatchQueue.main.async {
                    self.finishingCall = false
                    self.webRTCClient.stopCall()
                }
            }
    }
}

extension VideoCallViewModel: WebsocketsCallDelegate {
    func signalClient(_ websockets: Websockets, didAnswered data: String?) {
        webRTCClient.startCall {
            VideoCallViewModel.logger.error("VideoCallViewModel: Failed to start call")
        }
        DispatchQueue.main.async {
            self.answered = true
        }
    }
    
    func signalClient(_ websockets: Websockets, answeredFromAnotherDevice data: String?) {
        state = .dismissCall
        stopCall()
    }
    
    func signalClient(_ websockets: Websockets, hangUp data: String?) {
        state = .stopTalk
        stopCall()
    }
    
    func signalClient(_ websockets: Websockets, errorOffline data: String?) {
        state = .patientOffline
        Websockets.shared.hangUp(contractId: contractId)
        stopCall()
    }
    
    func signalClient(_ websockets: Websockets, errorConnection data: String?) {
        state = .disconnect
        Websockets.shared.hangUp(contractId: contractId)
        stopCall()
    }
}

extension VideoCallViewModel: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        DispatchQueue.main.async {
            self.rtcState = state
        }
    }
}
