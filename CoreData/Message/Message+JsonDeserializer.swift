//
//  Message+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension Message {
    public struct JsonDeserializer: Decodable {
        let id: Int
        let text: String
        let sent: String
        let deadline: String
        let isAnswered: Bool
        let isOvertime: Bool
        let isWarning: Bool
        let isDoctorMessage: Bool
        let attachments: Array<Attachment.JsonDeserializer>
        let images: Array<ImageAttachment.JsonDeserializer>
        let author: String
        let author_role: String?
        let is_auto: Bool?
        let state: String
        let is_agent: Bool?
        let action_type: String
        let action_link: String?
        let api_action_link: String?
        let action_name: String?
        let action_deadline: Date
        let action_onetime: Bool
        let action_used: Bool?
        let action_big: Bool
        let forward_to_doctor: Bool
        let only_doctor: Bool
        let only_patient: Bool
        let is_urgent: Bool
        let is_warning: Bool
        let is_filtered: Bool?
        let reply_to_id: Int?
        
        var sentAsDate: Date? {
            let formatter = DateFormatter.ddMMyyyyAndTime
            return formatter.date(from: sent)
        }
        
        var deadlineAsDate: Date? {
            let formatter = DateFormatter.ddMMyyyyAndTime
            return formatter.date(from: deadline)
        }
    }
    
    private static func saveFromJson(_ data: JsonDeserializer, for context: NSManagedObjectContext) -> Message {
        let message = get(id: data.id, for: context) ?? Message(context: context)
        
        message.id = Int64(data.id)
        message.text = data.text
        message.sent = data.sentAsDate
        message.deadline = data.deadlineAsDate
        message.isAnswered = data.isAnswered
        message.isOvertime = data.isOvertime
        message.isWarning = data.isWarning
        message.isDoctorMessage = data.isDoctorMessage
        message.author = data.author
        message.authorRole = data.author_role
        if let isAuto = data.is_auto {
            message.isAuto = isAuto
        }
        message.state = data.state
        if let isAgent = data.is_agent {
            message.isAgent = isAgent
        }
        message.actionType = data.action_type
        if let actionLink = data.action_link, let urlEncoded = actionLink.urlEncoded {
            message.actionLink = URL(string: urlEncoded)
        }
        if let apiActionLink = data.api_action_link, let urlEncoded = apiActionLink.urlEncoded {
            message.apiActionLink = URL(string: urlEncoded)
        }
        message.actionName = data.action_name
        message.actionDeadline = data.action_deadline
        message.actionOnetime = data.action_onetime
        if let actionUsed = data.action_used {
            message.actionUsed = actionUsed
        }
        message.actionBig = data.action_big
        message.forwardToDoctor = data.forward_to_doctor
        message.onlyDoctor = data.only_doctor
        message.onlyPatient = data.only_patient
        message.isUrgent = data.is_urgent
        message.isWarning = data.is_warning
        if let isFiltered = data.is_filtered {
            message.isFiltered = isFiltered
        }
        
        if let replyToId = data.reply_to_id {
            message.replyToId = Int64(replyToId)
            message.replyToMessage = Message.get(id: replyToId, for: context)
        }
        
        return message
    }
    
    public static func saveFromJson(_ data: JsonDeserializer, contractId: Int) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            guard let contract = Contract.get(id: contractId, for: context) else {
                Message.logger.error("Failed to save messages: Core data failed to fetch contract")
                return
            }
            
            let message = saveFromJson(data, for: context)
            
            for attachmentData in data.attachments {
                let attachment = Attachment.saveFromJson(attachmentData, for: context)
                if !message.attachmentsArray.contains(attachment) {
                    message.addToAttachments(attachment)
                }
            }
            
            for imageData in data.images {
                let image = ImageAttachment.saveFromJson(imageData, for: context)
                if !message.imagesArray.contains(image) {
                    message.addToImages(image)
                }
            }
            
            if !contract.messagesArray.contains(message) {
                contract.addToMessages(message)
            }
        }
    }
    
    /// Save messages objects from JSON decoded struct to Core Data
    /// - Parameters:
    ///   - data: struct decoded from JSON
    ///   - contractId: contract id for messages
    public static func saveFromJson(_ data: [JsonDeserializer], contractId: Int, completion: (() -> ())? = nil) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            guard let contract = Contract.get(id: contractId, for: context) else {
                Message.logger.error("Failed to save messages: Core data failed to fetch contract")
                return
            }
            
            var maxMessageId: Int = 0
            
            for messageData in data {
                let message = saveFromJson(messageData, for: context)
                
                for attachmentData in messageData.attachments {
                    let attachment = Attachment.saveFromJson(attachmentData, for: context)
                    if !message.attachmentsArray.contains(attachment) {
                        message.addToAttachments(attachment)
                    }
                }
                
                for imageData in messageData.images {
                    let image = ImageAttachment.saveFromJson(imageData, for: context)
                    if !message.imagesArray.contains(image) {
                        message.addToImages(image)
                    }
                }
                
                if !contract.messagesArray.contains(message) {
                    contract.addToMessages(message)
                }
                
                if messageData.id > maxMessageId {
                    maxMessageId = messageData.id
                }
            }
            
            PersistenceController.save(for: context, detailsForLogging: "Message from JsonDeserializer")
            if let completion = completion {
                completion()
            }
        }
    }
}
