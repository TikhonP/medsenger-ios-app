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
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter.date(from: sent)
        }
        
        var deadlineAsDate: Date? {
            let formatter = DateFormatter.ddMMyyyyAndTime
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter.date(from: deadline)
        }
    }
    
    private static func saveFromJson(_ data: JsonDeserializer, for moc: NSManagedObjectContext) -> Message {
        let message = (try? get(id: data.id, for: moc)) ?? Message(context: moc)
        
        message.id = Int64(data.id)
        
        if data.is_agent ?? false {
            message.text = HtmlParser.getMarkdownString(from: data.text)
        } else {
            message.text = data.text
        }
        
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
        if let actionLink = data.action_link {
            let components = actionLink.split(separator: "?")
            if components.count > 1, let urlEncoded = components.suffix(components.count - 1).joined(separator: "?").urlEncoded {
                message.actionLink = URL(string: components[0] + "?" + urlEncoded)
            } else {
                message.actionLink = URL(string: actionLink)
            }
        }
        if let apiActionLink = data.api_action_link {
            let components = apiActionLink.split(separator: "?")
            if components.count > 1, let urlEncoded = components.suffix(components.count - 1).joined(separator: "?").urlEncoded {
                message.apiActionLink = URL(string: components[0] + "?" + urlEncoded)
            } else {
                message.apiActionLink = URL(string: apiActionLink)
            }
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
            message.replyToMessage = try? Message.get(id: replyToId, for: moc)
        }
        
        return message
    }
    
    public static func saveFromJson(_ data: JsonDeserializer, contractId: Int) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let contract = try Contract.get(id: contractId, for: moc)
            
            let message = saveFromJson(data, for: moc)
            
            for attachmentData in data.attachments {
                let attachment = Attachment.saveFromJson(attachmentData, for: moc)
                if !message.attachmentsArray.contains(attachment) {
                    message.addToAttachments(attachment)
                }
            }
            
            for imageData in data.images {
                let image = ImageAttachment.saveFromJson(imageData, for: moc)
                if !message.imagesArray.contains(image) {
                    message.addToImages(image)
                }
            }
            
            if !contract.messagesArray.contains(message) {
                contract.addToMessages(message)
            }
            
            try markNextAndPreviousMessages(for: contract, for: moc)
            try moc.wrappedSave(detailsForLogging: "save message from json")
        }
    }
    
    /// Save messages objects from JSON decoded struct to Core Data
    /// - Parameters:
    ///   - data: struct decoded from JSON
    ///   - contractId: contract id for messages
    public static func saveFromJson(_ data: [JsonDeserializer], contractId: Int) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let contract = try Contract.get(id: contractId, for: moc)
            
            var maxMessageId: Int = 0
            
            for messageData in data {
                let message = saveFromJson(messageData, for: moc)
                
                for attachmentData in messageData.attachments {
                    let attachment = Attachment.saveFromJson(attachmentData, for: moc)
                    if !message.attachmentsArray.contains(attachment) {
                        message.addToAttachments(attachment)
                    }
                }
                
                for imageData in messageData.images {
                    let image = ImageAttachment.saveFromJson(imageData, for: moc)
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
            try markNextAndPreviousMessages(for: contract, for: moc)
            try moc.wrappedSave(detailsForLogging: "Message from JsonDeserializer")
        }
    }
}
