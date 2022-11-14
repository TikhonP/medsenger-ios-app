//
//  Messages.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class Messages {
    static let shared = Messages()
    
    private var getMessagesRequest: APIRequest<MessagesResource>?
    private var sendMessageRequest: APIRequest<SendMessageResouce>?
    
    public func getMessages(contractId: Int, completion: (() -> Void)? = nil) {
        let messagesResource = {
            guard let contract = Contract.get(id: contractId), contract.lastFetchedMessageId != 0 else {
                return MessagesResource(contractId: contractId)
            }
            return MessagesResource(contractId: contractId, fromMessageId: Int(contract.lastFetchedMessageId))
        }()
        
        getMessagesRequest = APIRequest(resource: messagesResource)
        getMessagesRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Message.saveFromJson(data: data, contractId: contractId)
                    if let completion = completion {
                        completion()
                    }
                }
            case .failure(let error):
                processRequestError(error, "get messages for contract \(contractId)")
            }
        }
    }
    
    public func sendMessage(_ text: String, contractId: Int, replyToId: Int? = nil, images: Array<(String, Data)> = [], attachments: Array<(String, Data)> = [], completion: (() -> Void)? = nil) {
        let sendMessageResource = SendMessageResouce(text, contractID: contractId, replyToId: replyToId, images: images, attachments: attachments)
        sendMessageRequest = APIRequest(resource: sendMessageResource)
        sendMessageRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Message.saveFromJson(data: data, contractId: contractId)
                    Contract.updateLastFetchedMessage(id: contractId, lastFetchedMessageId: data.id)
                    Websockets.shared.messageUpdate(contractId: contractId)
                    if let completion = completion {
                        completion()
                    }
                }
            case .failure(let error):
                processRequestError(error, "get messages for contract \(contractId)")
            }
        }
    }
}
