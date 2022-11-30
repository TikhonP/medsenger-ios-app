//
//  WebRTCClient.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import WebRTC
import os.log

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
}

final class WebRTCClient: NSObject {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: WebRTCClient.self)
    )
    
    // The `RTCPeerConnectionFactory` is in charge of creating new RTCPeerConnection instances.
    // A new RTCPeerConnection should be created every new call, but the factory is shared.
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    weak var delegate: WebRTCClientDelegate?
    
    private let contractId: Int
    private let peerConnection: RTCPeerConnection
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    private var videoCapturer: RTCVideoCapturer?
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    
    private var saveVideoCallRequest: APIRequest<SaveVideoCallResource>?
    
    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    required init(contractId: Int) {
        let config = RTCConfiguration()
        
        config.iceServers = AppConfig.iceServers
        
        // Unified plan is more superior than planB
        config.sdpSemantics = .unifiedPlan
        
        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        config.continualGatheringPolicy = .gatherContinually
        
        // Define media constraints. DtlsSrtpKeyAgreement is required to be true to be able to connect with web browsers.
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        
        guard let peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: nil) else {
            fatalError("Could not create new RTCPeerConnection")
        }
        
        self.peerConnection = peerConnection
        self.contractId = contractId
        
        super.init()
        self.createMediaSenders()
        self.configureAudioSession()
        self.peerConnection.delegate = self
        Websockets.shared.webRtcDelegate = self
    }
    
    public func startCall(failureCompletion: (() -> Void)? = nil) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        peerConnection.offer(for: constrains) { [weak self] (sdp, error) in
            if let error = error {
                if let failureCompletion = failureCompletion {
                    failureCompletion()
                }
                WebRTCClient.logger.error("WebRTCClient: offer error: \(error.localizedDescription)")
            }
            guard let sdp = sdp else {
                WebRTCClient.logger.error("startCall: No sdp")
                return
            }
            
            guard let self = self else { return }
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                if let error = error {
                    WebRTCClient.logger.error("WebRTCClient: setLocalDescription error: \(error.localizedDescription)")
                    if let failureCompletion = failureCompletion {
                        failureCompletion()
                    }
                    return
                }
                Websockets.shared.sendSdp(contractId: self.contractId, rtcSdp: sdp)
            })
        }
    }
    
    public func stopCall() {
        stopCaptureLocalVideo()
        stopAudioSession()
    }
    
    func stopAudioSession() {
        audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setActive(false)
            } catch {
                WebRTCClient.logger.error("WebRTCClient: Error disabling AudioSession: \(error.localizedDescription)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    // MARK: Media
    func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        guard let capturer = videoCapturer as? RTCCameraVideoCapturer else {
            return
        }
        
        guard
            let frontCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .front }),
            
                // choose highest res
            let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted { (f1, f2) -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                return width1 < width2
            }).last,
            
                // choose highest fps
            let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last) else {
            return
        }
        
        capturer.startCapture(with: frontCamera,
                              format: format,
                              fps: Int(fps.maxFrameRate))
        
        localVideoTrack?.add(renderer)
    }
    
    func stopCaptureLocalVideo(completionHandler: (() -> Void)? = nil) {
        guard let capturer = videoCapturer as? RTCCameraVideoCapturer else {
            return
        }
        capturer.stopCapture(completionHandler: completionHandler)
    }
    
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        remoteVideoTrack?.add(renderer)
    }
    
    func stopVideoRender(to renderer: RTCVideoRenderer) {
        remoteVideoTrack?.remove(renderer)
    }
    
    private func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void)  {
        let constrains = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        peerConnection.answer(for: constrains) { [weak self] (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            
            self?.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    private func configureAudioSession() {
        rtcAudioSession.lockForConfiguration()
        do {
            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch {
            WebRTCClient.logger.error("Error changeing AVAudioSession category: \(error)")
        }
        rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = createAudioTrack()
        peerConnection.add(audioTrack, streamIds: [streamId])
        
        // Video
        let videoTrack = createVideoTrack()
        localVideoTrack = videoTrack
        peerConnection.add(videoTrack, streamIds: [streamId])
        remoteVideoTrack = peerConnection.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
        
        // Data
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            localDataChannel = dataChannel
        }
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCClient.factory.videoSource()
        
#if targetEnvironment(simulator)
        videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
#else
        videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
#endif
        
        let videoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    // MARK: Data Channels
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = peerConnection.dataChannel(forLabel: "WebRTCData", configuration: config) else {
            WebRTCClient.logger.notice("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        remoteDataChannel?.sendData(buffer)
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        WebRTCClient.logger.debug("RTCPeerConnectionDelegate: peerConnection new signaling state: \(String(describing: stateChanged))")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        WebRTCClient.logger.debug("RTCPeerConnectionDelegate: peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        WebRTCClient.logger.debug("RTCPeerConnectionDelegate: peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        WebRTCClient.logger.debug("RTCPeerConnectionDelegate: peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        WebRTCClient.logger.debug("RTCPeerConnectionDelegate: peerConnection new connection state: \(String(describing: newState))")
        delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        WebRTCClient.logger.debug("RTCPeerConnectionDelegate: peerConnection new gathering state: \(String(describing: newState))")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        Websockets.shared.sendIce(contractId: contractId, rtcIceCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        WebRTCClient.logger.debug("RTCPeerConnectionDelegate: peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        WebRTCClient.logger.debug("RTCPeerConnectionDelegate: peerConnection did open data channel")
        remoteDataChannel = dataChannel
    }
}
extension WebRTCClient {
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool) {
        peerConnection.transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
}

// MARK: - Video control

extension WebRTCClient {
    func hideVideo() {
        setVideoEnabled(false)
    }
    
    func showVideo() {
        setVideoEnabled(true)
    }
    
    private func setVideoEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCVideoTrack.self, isEnabled: isEnabled)
    }
}

// MARK: - Audio control

extension WebRTCClient {
    func muteAudio() {
        setAudioEnabled(false)
    }
    
    func unmuteAudio() {
        setAudioEnabled(true)
    }
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
            } catch let error {
                WebRTCClient.logger.error("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    // Force speaker
    func speakerOn() {
        audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let error {
                WebRTCClient.logger.error("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    private func setAudioEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled)
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        WebRTCClient.logger.debug("dataChannel did change state: \(String(describing: dataChannel.readyState))")
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        let message = String(data: buffer.data, encoding: .utf8) ?? "(Binary: \(buffer.data.count) bytes)"
        WebRTCClient.logger.debug("WebRTCClient: didReceiveMessageWith: \(message)")
    }
}

extension WebRTCClient: WebsocketsWebRTCDelegate {
    func signalClient(_ websockets: Websockets, didReceiveRemoteSdp remoteSdp: RTCSessionDescription) {
        peerConnection.setRemoteDescription(remoteSdp) { [weak self] (error) in
            guard let self = self else {
                return
            }
            if let error = error {
                WebRTCClient.logger.error("WebRTCClient: didReceiveRemoteSdp error: \(error.localizedDescription)")
                Websockets.shared.invalidStream(contractId: self.contractId)
            } else {
                if remoteSdp.type == .offer {
                    self.answer { (localSdp) in
                        Websockets.shared.sendSdp(contractId: self.contractId, rtcSdp: localSdp)
                    }
                }
            }
        }
    }
    
    func signalClient(_ websockets: Websockets, didReceiveCandidate remoteCandidate: RTCIceCandidate) {
        peerConnection.add(remoteCandidate) { [weak self] (error) in
            guard let self = self else {
                return
            }
            if let error = error {
                WebRTCClient.logger.error("WebRTCClient: didReceiveCandidate error: \(error.localizedDescription)")
                Websockets.shared.invalidIce(contractId: self.contractId)
            }
        }
    }
}

extension WebRTCClient {
    func saveVideoCall(contractId: Int, talkStartTime: Date, callStartTime: Date, callEndTime: Date, state: CallState, dismissCall: Bool, completion: (() -> Void)? = nil) {
        let saveVideoCallResource = SaveVideoCallResource(
            contractId: contractId, talkStartTime: talkStartTime, callStartTime: callStartTime, callEndTime: callEndTime, state: state, dismissCall: dismissCall)
        saveVideoCallRequest = APIRequest(saveVideoCallResource)
        saveVideoCallRequest?.execute { result in
            switch result {
            case .success(_):
                if let completion = completion {
                    completion()
                }
            case .failure(let error):
                if let completion = completion {
                    processRequestError(error, "save video call data")
                    completion()
                }
            }
        }
    }
}
