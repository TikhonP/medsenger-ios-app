//
//  Messages.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class Messages {
    
    /// Fetch messages for contract
    ///
    /// When some messages for contract already fetched, it messages from last fetched message
    /// - Parameter contractId: Contract Id
    /// - Returns: Is first fetch messages for this contract
    public static func fetchMessages(contractId: Int) async throws -> Bool {
        let contract = try? await Contract.get(id: contractId)
        let lastFetchedMessageId = await MainActor.run {
            contract?.lastFetchedMessage?.id
        }
        let messagesResource = {
            guard let lastFetchedMessageId = lastFetchedMessageId  else {
                return MessagesResource(contractId: contractId, fromMessageId: nil)
            }
            return MessagesResource(contractId: contractId, fromMessageId: Int(lastFetchedMessageId))
        }()
        do {
            let data = try await APIRequest(messagesResource).executeWithResult()
            try await Message.saveFromJson(data, contractId: contractId)
            try await Contract.updateLastAndFirstFetchedMessage(id: contractId)
            return lastFetchedMessageId == nil
        } catch {
            throw await processRequestError(error, "get messages for contract \(contractId)", apiErrors: messagesResource.apiErrors)
        }
    }
    
    /// Send message to chat
    /// - Parameters:
    ///   - text: Message text
    ///   - contractId: Chat contract id
    ///   - replyToId: If message is reply, reply to message id
    ///   - attachments: Attachments as tuple with filename and data
    public static func sendMessage(_ text: String, for contractId: Int, replyToId: Int? = nil, attachments: Array<ChatViewAttachment> = []) async throws {
        let sendMessageResource = SendMessageResouce(text: text, contractID: contractId, replyToId: replyToId, attachments: attachments)
        do {
            let data = try await APIRequest(sendMessageResource).executeWithResult()
            try await Message.saveFromJson(data, contractId: contractId)
            try await Contract.updateLastAndFirstFetchedMessage(id: contractId)
            Websockets.shared.messageUpdate(contractId: contractId)
        } catch {
            throw await processRequestError(error, "send message for contract \(contractId)", apiErrors: sendMessageResource.apiErrors)
        }
    }
    
    /// Fetch file for message attachment and save it
    /// - Parameters:
    ///   - attachmentId: Attachment Id
    public static func fetchAttachmentData(attachmentId: Int) async throws -> URL {
        do {
            let data = try await FileRequest(path: "/attachments/\(attachmentId)").executeWithResult()
            return try await Attachment.saveFile(id: attachmentId, data: data)
        } catch {
            throw await processRequestError(error, "Messages: fetchAttachmentData")
        }
    }
    
    /// Fetch image file for message image attachment and save it
    /// - Parameters:
    ///   - imageAttachmentId: Image Attachment Id
    public static func fetchImageAttachmentImage(imageAttachmentId: Int) async throws -> URL {
        do {
            let data = try await FileRequest(path: "/images/\(imageAttachmentId)/real").executeWithResult()
            return try await ImageAttachment.saveFile(id: imageAttachmentId, data: data)
        } catch {
            throw await processRequestError(error, "Messages: fetchImageAttachmentImage")
        }
    }
    
    /// Mark action message as used
    /// - Parameters:
    ///   - messageId: Message Id
    public static func messageActionUsed(messageId: Int) async throws {
        let actionUsedResource = ActionUsedResource(messageId: messageId)
        do {
            try await APIRequest(actionUsedResource).execute()
        } catch {
            throw await processRequestError(error, "Messages: messageActionUsed", apiErrors: actionUsedResource.apiErrors)
        }
    }
}
