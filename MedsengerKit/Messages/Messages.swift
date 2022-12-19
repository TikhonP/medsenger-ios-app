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
    private var getLast10MessagesRequests = [APIRequest<MessagesResource>]()
    private var sendMessageRequest: APIRequest<SendMessageResouce>?
    private var getAttachmentRequests = [FileRequest]()
    
    public func fetchLast10Messages(contractId: Int) {
        let messagesResource = {
            guard let contract = Contract.get(id: contractId), let lastFetchedMessage = contract.lastGlobalFetchedMessage else {
                return MessagesResource(contractId: contractId, fromMessageId: nil, minId: nil, maxId: nil, desc: true, offset: 0, limit: 10)
            }
            return MessagesResource(contractId: contractId, fromMessageId: Int(lastFetchedMessage.id), minId: nil, maxId: nil, desc: true, offset: nil, limit: nil)
        }()
        let getLast10MessagesRequest = APIRequest(messagesResource)
        getLast10MessagesRequests.append(getLast10MessagesRequest)
        getLast10MessagesRequest.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Message.saveFromJson(data, contractId: contractId) {
                        Contract.updateLastAndFirstFetchedMessage(id: contractId, updateGlobal: false)
                    }
                }
            case .failure(let error):
                processRequestError(error, "get messages for contract \(contractId)")
            }
        }
    }
    
    public func fetchMessages(contractId: Int, completion: @escaping (_ succeeded: Bool) -> Void) {
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
    public func sendMessage(_ text: String, for contractId: Int, replyToId: Int? = nil, attachments: Array<ChatViewAttachment> = [], completion: @escaping (_ succeeded: Bool) -> Void) {
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
                switch failureError {
                case .api(let errorsResponse, _):
                    completion(false)
                    if errorsResponse.errors.contains("too large file") {
                        print("too large file")
                    } else {
                        processRequestError(failureError, "send message for contract \(contractId)")
                    }
                case .failedToDeserialize(let statusCode, _):
                    processRequestError(failureError, "send message for contract \(contractId)")
                    if statusCode == 200 {
                        // If request success but response data from server corrupted
                        completion(true)
                    } else {
                        completion(false)
                    }
                default:
                    completion(false)
                    processRequestError(failureError, "send message for contract \(contractId)")
                }
            }
        }
    }
    
    public func fetchAttachmentData(attachmentId: Int, completion: @escaping (_ succeeded: Bool) -> Void) {
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
    
    public func fetchImageAttachmentImage(imageAttachmentId: Int, completion: @escaping (_ succeeded: Bool) -> Void) {
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
}
