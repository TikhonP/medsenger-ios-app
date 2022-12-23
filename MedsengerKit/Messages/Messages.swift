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
    
    private var getAllMessagesRequest: APIRequest<MessagesResource>?
    private var sendMessageRequest: APIRequest<SendMessageResouce>?
    private var actionUsedRequest: APIRequest<ActionUsedResource>?
    private var getAttachmentRequests = [FileRequest]()
    
    /// Fetch messages for contract
    ///
    /// When some messages for contract already fetched, it messages from last fetched message
    /// - Parameters:
    ///   - contractId: Contract Id
    ///   - completion: Request completion
    public func fetchMessages(contractId: Int, completion: @escaping APIRequestCompletion) {
        let messagesResource = {
            guard let contract = Contract.get(id: contractId), let lastFetchedMessage = contract.lastFetchedMessage else {
                return MessagesResource(contractId: contractId, fromMessageId: nil, minId: nil, maxId: nil, desc: true, offset: nil, limit: nil)
            }
            return MessagesResource(contractId: contractId, fromMessageId: Int(lastFetchedMessage.id), minId: nil, maxId: nil, desc: true, offset: nil, limit: nil)
        }()
        getAllMessagesRequest = APIRequest(messagesResource)
        getAllMessagesRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Message.saveFromJson(data, contractId: contractId) {
                        Contract.updateLastAndFirstFetchedMessage(id: contractId, updateGlobal: true)
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            case .failure(let error):
                completion(false)
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
    public func sendMessage(_ text: String, for contractId: Int, replyToId: Int? = nil, attachments: Array<ChatViewAttachment> = [], completion: @escaping APIRequestCompletion) {
        let sendMessageResource = SendMessageResouce(text: text, contractID: contractId, replyToId: replyToId, attachments: attachments)
        sendMessageRequest = APIRequest(sendMessageResource)
        sendMessageRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Message.saveFromJson(data, contractId: contractId)
                    Contract.updateLastAndFirstFetchedMessage(id: contractId, updateGlobal: false)
                    Websockets.shared.messageUpdate(contractId: contractId)
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let failureError):
                completion(false)
                processRequestError(failureError, "send message for contract \(contractId)")
            }
        }
    }
    
    /// Fetch file for message attachment and save it
    /// - Parameters:
    ///   - attachmentId: Attachment Id
    ///   - completion: Request completion
    public func fetchAttachmentData(attachmentId: Int, completion: @escaping APIRequestCompletion) {
        let getAttachmentRequest = FileRequest(path: "/attachments/\(attachmentId)")
        getAttachmentRequests.append(getAttachmentRequest)
        getAttachmentRequest.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Attachment.saveFile(id: attachmentId, data: data)
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let error):
                completion(false)
                processRequestError(error, "Messages: fetchAttachmentData")
            }
        }
    }
    
    /// Fetch image file for message image attachment and save it
    /// - Parameters:
    ///   - imageAttachmentId: Image Attachment Id
    ///   - completion: Request completion
    public func fetchImageAttachmentImage(imageAttachmentId: Int, completion: @escaping APIRequestCompletion) {
        let getImageAttachmentImagegetAttachmentRequest = FileRequest(path: "/images/\(imageAttachmentId)/real")
        getAttachmentRequests.append(getImageAttachmentImagegetAttachmentRequest)
        getImageAttachmentImagegetAttachmentRequest.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    ImageAttachment.saveFile(id: imageAttachmentId, data: data)
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let error):
                completion(false)
                processRequestError(error, "Messages: fetchImageAttachmentImage")
            }
        }
    }
    
    /// Mark action message as used
    /// - Parameters:
    ///   - messageId: Message Id
    ///   - completion: Request completion
    public func messageActionUsed(messageId: Int, completion: @escaping APIRequestCompletion) {
        let actionUsedResource = ActionUsedResource(messageId: messageId)
        actionUsedRequest = APIRequest(actionUsedResource)
        actionUsedRequest?.execute { result in
            switch result {
            case .success(_):
                Message.markActionMessageAsUsed(id: messageId)
                completion(true)
            case .failure(let error):
                completion(false)
                processRequestError(error, "Messages: messageActionUsed")
            }
        }
    }
}
