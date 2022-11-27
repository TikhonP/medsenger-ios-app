//
//  Websockets.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 10.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import WebRTC

protocol WebsocketsWebRTCDelegate: AnyObject {
    func signalClient(_ websockets: Websockets, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ websockets: Websockets, didReceiveCandidate candidate: RTCIceCandidate)
}

protocol WebsocketsCallDelegate: AnyObject {
    func signalClient(_ websockets: Websockets, didAnswered data: String?)
    func signalClient(_ websockets: Websockets, answeredFromAnotherDevice data: String?)
    func signalClient(_ websockets: Websockets, hangUp data: String?)
}

class Websockets: NSObject {
    static let shared = Websockets()
    
    private var webSocket: URLSessionWebSocketTask?
    
    private(set) var isConnected: Bool = false
    
    weak var webRtcDelegate: WebsocketsWebRTCDelegate?
    weak var callDelegate: WebsocketsCallDelegate?
    
    // MARK: - Public methods
    
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
    
    // MARK: - Private methods
    
    private func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("Websocket ping error: \(error.localizedDescription)")
            }
        }
    }
    
    private func send(_ request: some WebsocketRequest) {
        ping()
        guard let message = request.data else {
            print("Webscoket request data is nil")
            return
        }
        print("WEBSOCKET send: \(message)")
        webSocket?.send(.string(message), completionHandler: { error in
            if let error = error {
                print("Websocket send error: \(error.localizedDescription)")
            }
        })
    }
    
    private func processWebsocketResponse(_ websocketResponse: some WebsocketResponse, _ data: String, responseStatus: WebsocketResponseStatus) {
        let decodingResult = websocketResponse.decode(data)
        if self.webRtcDelegate == nil {
            print("self.webRtcDelegate == nil!!!")
        } else {
            print("self.webRtcDelegate != nil!!!")
        }
        switch decodingResult {
        case .success(let data):
            switch responseStatus {
            case .sdp:
                guard let data = data as? SdpWebsocketResponse.Model else {
                    print("Websockets: processWebsocketResponse: Failed to get sdp")
                    return
                }
                self.webRtcDelegate?.signalClient(self, didReceiveRemoteSdp: data.sdp.rtcSessionDescription)
            case .ice:
                guard let data = data as? IceWebsocketResponse.Model else {
                    print("Websockets: processWebsocketResponse: Failed to get ice")
                    return
                }
                self.webRtcDelegate?.signalClient(self, didReceiveCandidate: data.ice.rtcIceCandidate)
            case .answered:
                self.callDelegate?.signalClient(self, didAnswered: "")
            case .answeredFromAnotherDevice:
                self.callDelegate?.signalClient(self, answeredFromAnotherDevice: "")
            case .hangUp:
                self.callDelegate?.signalClient(self, hangUp: "")
            default:
                websocketResponse.processResponse(data)
            }
        case .failure(let error):
            print("Websocket received: Decoding data error: \(error.localizedDescription)")
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
                print("Websocket received data: \(data)")
            case .string(let string):
                if string == "ping" {
                    webSocket?.send(.string("pong"), completionHandler: { error in
                        if let error = error {
                            print("Websocket send pong error: \(error.localizedDescription)")
                        }
                    })
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let status = try decoder.decode(WebsocketResponseStatusModel.self, from: Data(string.utf8))
                        let websocketResponse = WebsocketResponseStatus.getWebsocketResponse(status.mType)
                        print("Websocket got: \(status.mType) \(string)")
                        processWebsocketResponse(websocketResponse, string, responseStatus: status.mType)
                    } catch {
                        return print("Websocket received: Decoding status error: \(error.localizedDescription) Data: \(string)")
                        
                    }
                }
            @unknown default:
                print("Websocket received: Unknown message")
            }
        case .failure(let error as NSError):
            switch error.code {
            case 53: // Software caused connection abort
                print("Websocket receive connection aborted")
                isConnected = false
                close()
            default:
                print("Websocket receive error: \(error.localizedDescription)")
            }
        }
    }
    
    private func close() {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
}

// MARK: - `URLSessionWebSocketDelegate` delegate

extension Websockets: URLSessionWebSocketDelegate {
    internal func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Websockets: Connection established")
        isConnected = true
        ping()
        receive()
        send(IAmWebsocketRequest())
    }
    
    internal func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        print("Websockets: Did closed connection with reason: \(String(describing: reason))")
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            print("Websockets: Trying to reconnect to websocket server...")
            self.createUrlSession()
        }
    }
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as? URLError {
            if error.code == .timedOut  || error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
                isConnected = false
                close()
            } else {
                print("Websockets: didCompleteWithError: URLError: \(error.localizedDescription)")
            }
        } else if let error = error {
            print("Websockets: didCompleteWithError: \(error.localizedDescription)")
        } else {
            print("Websockets: didCompleteWithError: error is nil")
        }
    }
}

