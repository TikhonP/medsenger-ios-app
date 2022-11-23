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
    private var getAttachmentRequests = [FileRequest]()
    
    public func getMessages(contractId: Int, completion: (() -> Void)? = nil) {
        let messagesResource = {
            guard let contract = Contract.get(id: contractId), let lastFetchedMessage = contract.lastFetchedMessage else {
                return MessagesResource(contractId: contractId)
            }
            return MessagesResource(contractId: contractId, fromMessageId: Int(lastFetchedMessage.id))
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
    
    public func sendMessage(_ text: String, contractId: Int, replyToId: Int? = nil, images: Array<(String, Data)> = [], attachments: Array<URL> = [], completion: (() -> Void)? = nil) {
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
                processRequestError(error, "send message for contract \(contractId)")
            }
        }
    }
    
    public func fetchAttachmentData(attachmentId: Int, completion: (() -> Void)? = nil) {
        let getAttachmentRequest = FileRequest(path: "/attachments/\(attachmentId)")
        getAttachmentRequests.append(getAttachmentRequest)
        getAttachmentRequest.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Attachment.saveFile(id: attachmentId, data: data)
                    if let completion = completion {
                        completion()
                    }
                }
            case .failure(let error):
                processRequestError(error, "get doctor avatar")
            }
        }
    }
}
