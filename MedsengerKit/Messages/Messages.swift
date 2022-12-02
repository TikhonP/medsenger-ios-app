//
//  Messages.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class Messages {
    static let shared = Messages()
    
    private var getMessagesRequest: APIRequest<MessagesResource>?
    private var sendMessageRequest: APIRequest<SendMessageResouce>?
    private var getAttachmentRequests = [FileRequest]()
    
    public func fetchMessages(contractId: Int, completion: (() -> Void)? = nil) {
        let messagesResource = {
            guard let contract = Contract.get(id: contractId), let lastFetchedMessage = contract.lastFetchedMessage else {
                return MessagesResource(for: contractId)
            }
            return MessagesResource(for: contractId, fromMessageId: Int(lastFetchedMessage.id))
        }()
        
        getMessagesRequest = APIRequest(messagesResource)
        getMessagesRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Message.saveFromJson(data, contractId: contractId) {
                        Contract.updateLastFetchedMessage(id: contractId)
                        if let completion = completion {
                            completion()
                        }
                    }
                }
            case .failure(let error):
                processRequestError(error, "get messages for contract \(contractId)")
            }
        }
    }
    
    /// Send message to chat
    /// - Parameters:
    ///   - text: Message text
    ///   - contractId: Chat contract id
    ///   - replyToId: If message is reply, reply to message id
    ///   - attachments: Attachments as tuple with filename and data
    ///   - completion: Request completion
    public func sendMessage(_ text: String, for contractId: Int, replyToId: Int? = nil, attachments: Array<(String, Data)> = [], completion: (() -> Void)? = nil) {
        let sendMessageResource = SendMessageResouce(text: text, contractID: contractId, replyToId: replyToId, attachments: attachments)
        sendMessageRequest = APIRequest(sendMessageResource)
        sendMessageRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Message.saveFromJson(data, contractId: contractId)
                    Contract.updateLastFetchedMessage(id: contractId)
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
