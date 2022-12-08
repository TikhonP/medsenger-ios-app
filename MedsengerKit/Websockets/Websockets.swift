//
//  Websockets.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 10.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import WebRTC
import os.log

protocol WebsocketsWebRTCDelegate: AnyObject {
    func signalClient(_ websockets: Websockets, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ websockets: Websockets, didReceiveCandidate candidate: RTCIceCandidate)
}

protocol WebsocketsCallDelegate: AnyObject {
    func signalClient(_ websockets: Websockets, didAnswered data: String?)
    func signalClient(_ websockets: Websockets, answeredFromAnotherDevice data: String?)
    func signalClient(_ websockets: Websockets, hangUp data: String?)
    func signalClient(_ websockets: Websockets, errorOffline data: String?)
    func signalClient(_ websockets: Websockets, errorConnection data: String?)
}

protocol WebsocketsContentViewModelDelegate: AnyObject {
    func signalClient(_ websockets: Websockets, callWithContractId contractId: Int)
    func signalClient(_ websockets: Websockets, callContinuedWithContractId contractId: Int)
}

class Websockets: NSObject {
    
    static let shared = Websockets()
    
    private var webSocket: URLSessionWebSocketTask?
    private(set) var isConnected: Bool = false
    
    weak var webRtcDelegate: WebsocketsWebRTCDelegate?
    weak var callDelegate: WebsocketsCallDelegate?
    weak var contentViewModelDelegate: WebsocketsContentViewModelDelegate?
    
    // MARK: - Private methods
    
    private func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                Logger.websockets.error("Websocket ping error: \(error.localizedDescription)")
            }
        }
    }
    
    private func send(_ request: some WebsocketRequest) {
        ping()
        guard let message = request.data else {
            Logger.websockets.error("Webscokets: send: request data is nil")
            return
        }
        webSocket?.send(.string(message), completionHandler: { error in
            if let error = error {
                Logger.websockets.error("Websocket send error: \(error.localizedDescription)")
            }
        })
    }
    
    private func processWebsocketResponse(_ websocketResponse: some WebsocketResponse, _ data: String, responseStatus: WebsocketResponseStatus) {
        let decodingResult = websocketResponse.decode(data)
        switch decodingResult {
        case .success(let data):
            websocketResponse.processResponse(data)
            
            switch responseStatus {
            case .sdp:
                guard let data = data as? SdpWebsocketResponse.Model else {
                    Logger.websockets.error("Websockets: processWebsocketResponse: Failed to get SdpWebsocketResponse.Model")
                    return
                }
                webRtcDelegate?.signalClient(self, didReceiveRemoteSdp: data.sdp.rtcSessionDescription)
            case .ice:
                guard let data = data as? IceWebsocketResponse.Model else {
                    Logger.websockets.error("Websockets: processWebsocketResponse: Failed to get IceWebsocketResponse.Model")
                    return
                }
                webRtcDelegate?.signalClient(self, didReceiveCandidate: data.ice.rtcIceCandidate)
            case .answered:
                callDelegate?.signalClient(self, didAnswered: nil)
            case .answeredFromAnotherDevice:
                callDelegate?.signalClient(self, answeredFromAnotherDevice: nil)
            case .hangUp:
                callDelegate?.signalClient(self, hangUp: nil)
            case .errOffline:
                callDelegate?.signalClient(self, errorOffline: nil)
            case .errConnection:
                callDelegate?.signalClient(self, errorConnection: nil)
            case .call:
                guard let data = data as? CallWebsocketResponse.Model else {
                    Logger.websockets.error("Websockets: processWebsocketResponse: Failed to get CallWebsocketResponse.Model")
                    return
                }
                contentViewModelDelegate?.signalClient(self, callWithContractId: data.contract_id)
            case .callContinued:
                guard let data = data as? CallContinuedWebsocketResponse.Model else {
                    Logger.websockets.error("Websockets: processWebsocketResponse: Failed to get CallContinuedWebsocketResponse.Model")
                    return
                }
                contentViewModelDelegate?.signalClient(self, callWithContractId: data.contract_id)
            default:
                break
            }
        case .failure(let error):
            if let error = error as? DecodingError {
                switch error {
                case .typeMismatch(let type, let context):
                    Logger.websockets.error("Websocket received: Decoding data error: typeMismatch for key `\(type)`: \(error.localizedDescription) Context: \(String(describing: context)) Data: \(data)")
                case .valueNotFound(let value, let context):
                    Logger.websockets.error("Websocket received: Decoding data error: valueNotFound for value `\(String(describing: value))`: \(error.localizedDescription) Context: \(String(describing: context)) Data: \(data)")
                case .keyNotFound(let key, let context):
                    Logger.websockets.error("Websocket received: Decoding data error: keyNotFound for key `\(String(describing: key))`: \(error.localizedDescription) Context: \(String(describing: context)) Data: \(data)")
                case .dataCorrupted(let context):
                    Logger.websockets.error("Websocket received: Decoding data error: dataCorrupted: \(error.localizedDescription) Context: \(String(describing: context)) Data: \(data)")
                @unknown default:
                    Logger.websockets.error("Websocket received: Decoding data error: \(error.localizedDescription) Data: \(data)")
                }
            } else {
                Logger.websockets.error("Websocket received: Decoding data error: \(error.localizedDescription) Data: \(data)")
            }
        }
    }
    
    private func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            self?.receiveCompletion(result)
            if let isConnected = self?.isConnected, isConnected {
                self?.receive()
            }
        })
    }
    
    private func receiveCompletion(_ result: Result<URLSessionWebSocketTask.Message, Error>) {
        switch result {
        case .success(let message):
            switch message {
            case .data(let data):
                Logger.websockets.notice("Websocket received data: \(data)")
            case .string(let string):
                if string == "ping" {
                    webSocket?.send(.string("pong"), completionHandler: { error in
                        if let error = error {
                            Logger.websockets.error("Websocket send pong error: \(error.localizedDescription)")
                        }
                    })
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let status = try decoder.decode(WebsocketResponseStatusModel.self, from: Data(string.utf8))
                        let websocketResponse = WebsocketResponseStatus.getWebsocketResponse(status.mType)
                        processWebsocketResponse(websocketResponse, string, responseStatus: status.mType)
                    } catch {
                        Logger.websockets.error("Websocket received: Decoding status error: \(error.localizedDescription) Data: \(string)")
                    }
                }
            @unknown default:
                Logger.websockets.notice("Websocket received: Unknown message")
            }
        case .failure(let error as NSError):
            switch error.code {
            case 53: // Software caused connection abort
                Logger.websockets.notice("Websocket receive connection aborted")
                isConnected = false
                close()
            default:
                Logger.websockets.error("Websocket receive error: \(error.localizedDescription)")
            }
        }
    }
    
    func close() {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
}

// MARK: - `URLSessionWebSocketDelegate` delegate

extension Websockets: URLSessionWebSocketDelegate {
    internal func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Logger.websockets.debug("Websockets: Connection established")
        isConnected = true
        ping()
        receive()
        send(IAmWebsocketRequest())
    }
    
    internal func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        Logger.websockets.notice("Websockets: Did closed connection with reason: \(String(describing: reason))")
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
            Logger.websockets.debug("Websockets: Trying to reconnect to websocket server...")
            self?.createUrlSession()
        }
    }
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as? URLError {
            if error.code == .timedOut  || error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
                isConnected = false
                close()
            } else {
                Logger.websockets.error("Websockets: didCompleteWithError: URLError: \(error.localizedDescription)")
            }
        } else if let error = error {
            Logger.websockets.error("Websockets: didCompleteWithError: \(error.localizedDescription)")
        } else {
            Logger.websockets.error("Websockets: didCompleteWithError: error is nil")
        }
    }
}

// MARK: - Public methods

extension Websockets {
    public func createUrlSession() {
        if webSocket == nil || !isConnected {
            let session = URLSession(
                configuration: .default,
                delegate: self,
                delegateQueue: OperationQueue()
            )
            webSocket = session.webSocketTask(with: Constants.medsengerWebsocketUrl)
            webSocket?.resume()
        }
    }
    
    public func messageUpdate(contractId: Int) {
        send(MessageUpdateWebsocketRequest(contractId: contractId))
    }
    
    public func sendIce(contractId: Int, rtcIceCandidate: RTCIceCandidate) {
        send(IceWebsocketRequest(
            contractId: contractId, rtcIceCandidate: rtcIceCandidate))
    }
    
    public func sendSdp(contractId: Int, rtcSdp: RTCSessionDescription) {
        send(SdpWebsocketRequest(
            contractId: contractId, rtcSdp: rtcSdp))
    }
    
    public func hangUp(contractId: Int) {
        send(HangUpWebsocketRequest(contractId: contractId))
    }
    
    public func makeCall(contractId: Int) {
        send(CallWebsocketRequest(contractId: contractId))
    }
    
    public func invalidIce(contractId: Int) {
        send(InvalidIceWebsocketRequest(contractId: contractId))
    }
    
    public func invalidStream(contractId: Int) {
        send(InvalidStreamWebsocketRequest(contractId: contractId))
    }
    
    public func answer(contractId: Int) {
        send(AnswerWebsocketRequest(contractId: contractId))
    }
}
