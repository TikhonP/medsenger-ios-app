//
//  VideoCallViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import WebRTC

final class VideoCallViewModel: ObservableObject {
    let webRTCClient: WebRTCClient
    
    private let contractId: Int
    private weak var contentViewModel: ContentViewModel?
    
    @Published var state: RTCIceConnectionState = .new
    @Published var answered: Bool = false
    
    required init(contractId: Int, contentViewModel: ContentViewModel) {
        self.contractId = contractId
        self.webRTCClient = WebRTCClient(contractId: contractId)
        self.contentViewModel = contentViewModel
        self.webRTCClient.delegate = self
        Websockets.shared.callDelegate = self
    }
    
    func makeCall() {
        Websockets.shared.makeCall(contractId: contractId)
    }
    
    func hangUp() {
        Websockets.shared.hangUp(contractId: contractId)
        self.contentViewModel?.isCalling = false
    }
}

extension VideoCallViewModel: WebsocketsCallDelegate {
    func signalClient(_ websockets: Websockets, didAnswered data: String?) {
        print("Answered")
        self.webRTCClient.startCall {
            print("Failed")
        }
        DispatchQueue.main.async {
            self.answered = true
        }
    }
    
    func signalClient(_ websockets: Websockets, answeredFromAnotherDevice data: String?) {
        DispatchQueue.main.async {
            self.contentViewModel?.isCalling = false
        }
    }
    
    func signalClient(_ websockets: Websockets, hangUp data: String?) {
        DispatchQueue.main.async {
            print("Hang up")
            self.contentViewModel?.isCalling = false
            self.webRTCClient.hideVideo()
            self.webRTCClient.muteAudio()
            self.webRTCClient.speakerOff()
            
        }
    }
}

extension VideoCallViewModel: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
}
