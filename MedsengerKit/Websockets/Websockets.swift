//
//  Websockets.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 10.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class Websockets: NSObject, URLSessionWebSocketDelegate {
    static let shared = Websockets()
    
    private var webSocket: URLSessionWebSocketTask?
    
    private(set) var isConnected: Bool = false
    
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
        webSocket?.send(.string(message), completionHandler: { error in
            if let error = error {
                print("Websocket send error: \(error.localizedDescription)")
            }
        })
    }
    
    private func processWebsocketResponse(_ websocketResponse: some WebsocketResponse, _ data: String) {
        let decodingResult = websocketResponse.decode(data)
        
        switch decodingResult {
        case .success(let data):
            websocketResponse.processResponse(data)
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
                        
                        processWebsocketResponse(websocketResponse, string)
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
    
    internal func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Websocket connection established")
        isConnected = true
        ping()
        receive()
        send(IAmWebsocketRequest())
    }
    
    internal func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        print("Did closed connection with reason: \(String(describing: reason))")
    }
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as? URLError {
            if error.code == .timedOut  || error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
                isConnected = false
                close()
            }
        }
    }
}
