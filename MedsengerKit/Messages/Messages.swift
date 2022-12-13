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
    
    public func fetchMessages(contractId: Int, minId: Int? = nil, maxId: Int? = nil, desc: Bool = false, offset: Int? = nil, limit: Int? = nil, completion: (() -> Void)? = nil) {
        let messagesResource = {
            guard minId == nil, maxId == nil, offset == nil, limit == nil else {
                return MessagesResource(contractId: contractId, fromMessageId: nil, minId: minId, maxId: maxId, desc: desc, offset: offset, limit: limit)
            }
            guard let contract = Contract.get(id: contractId), let lastFetchedMessage = contract.lastFetchedMessage else {
                return MessagesResource(contractId: contractId, fromMessageId: nil, minId: nil, maxId: nil, desc: true, offset: 0, limit: 30)
            }
            return MessagesResource(contractId: contractId, fromMessageId: Int(lastFetchedMessage.id), minId: nil, maxId: nil, desc: desc, offset: nil, limit: nil)
        }()
        
        getMessagesRequest = APIRequest(messagesResource)
        getMessagesRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Message.saveFromJson(data, contractId: contractId) {
                        Contract.updateLastAndFirstFetchedMessage(id: contractId)
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
    public func sendMessage(_ text: String, for contractId: Int, replyToId: Int? = nil, attachments: Array<ChatViewAttachment> = [], completion: @escaping (_ succeeded: Bool) -> Void) {
        let sendMessageResource = SendMessageResouce(text: text, contractID: contractId, replyToId: replyToId, attachments: attachments)
        sendMessageRequest = APIRequest(sendMessageResource)
        sendMessageRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Message.saveFromJson(data, contractId: contractId)
                    Contract.updateLastAndFirstFetchedMessage(id: contractId)
                    Websockets.shared.messageUpdate(contractId: contractId)
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let failureError):
                completion(false)
                switch failureError {
                case .api(let errorsResponse, _):
                    if errorsResponse.errors.contains("too large file") {
                        print("too large file")
                    }
                default:
                    processRequestError(failureError, "send message for contract \(contractId)")
                }
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
                processRequestError(error, "Messages: fetchAttachmentData")
            }
        }
    }
    
    public func fetchImageAttachmentImage(imageAttachmentId: Int) {
        let getImageAttachmentImagegetAttachmentRequest = FileRequest(path: "/images/\(imageAttachmentId)/real")
        getAttachmentRequests.append(getImageAttachmentImagegetAttachmentRequest)
        getImageAttachmentImagegetAttachmentRequest.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    ImageAttachment.saveFile(id: imageAttachmentId, data: data)
                }
            case .failure(let error):
                processRequestError(error, "Messages: fetchImageAttachmentImage")
            }
        }
    }
}
