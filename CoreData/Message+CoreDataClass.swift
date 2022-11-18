//
//  Message+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(Message)
public class Message: NSManagedObject {
    var isMessageSent: Bool {
        switch Account.shared.role {
        case .patient:
            return !isDoctorMessage
        case .doctor:
            return isDoctorMessage
        }
    }
    
    class func get(id: Int, context: NSManagedObjectContext) -> Message? {
        do {
            let fetchRequest = Message.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            let fetchedResults = try context.fetch(fetchRequest)
            if let message = fetchedResults.first {
                return message
            }
            return nil
        }
        catch {
            print("Fetch core data task failed: ", error.localizedDescription)
            return nil
        }
    }
}

extension Message {
    struct JsonDeserializer: Decodable {
        let id: Int
        let text: String
        let sent: String
        let deadline: String
        let isAnswered: Bool
        let isOvertime: Bool
        let isWarning: Bool
        let isDoctorMessage: Bool
        let attachments: Array<Attachment.JsonDeserializer>
        let images: Array<ImageAttachment.JsonSerializer>
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
    
private class func saveFromJson(data: JsonDeserializer, context: NSManagedObjectContext) -> Message {
        let message = {
            if let message = get(id: data.id, context: context) {
                return message
            } else {
                return Message(context: context)
            }
        }()
        
        if data.isSimilar(message) {
            return message
        }
        
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
        }
        
        PersistenceController.save(context: context)
        
        return message
    }
    
    class func saveFromJson(data: JsonDeserializer, contractId: Int) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            guard let contract = Contract.get(id: contractId, context: context) else {
                print("Failed to save messages: Core data failed to fetch contract")
                return
            }
            
            let message = saveFromJson(data: data, context: context)
            
            for attachmentData in data.attachments {
                let attachment = Attachment.saveFromJson(data: attachmentData, context: context)
                if let isExist = message.attachments?.contains(attachment), !isExist {
                    message.addToAttachments(attachment)
                }
            }
            
            for imageData in data.images {
                let image = ImageAttachment.saveFromJson(data: imageData, context: context)
                if let isExist = message.images?.contains(image), !isExist {
                    message.addToImages(image)
                }
            }
            
            if let isExist = contract.messages?.contains(message), !isExist {
                contract.addToMessages(message)
                PersistenceController.save(context: context)
            }
        }
    }
    
    /// Save messages objects from JSON decoded struct to Core Data
    /// - Parameters:
    ///   - data: struct decoded from JSON
    ///   - contractId: contract id for messages
    class func saveFromJson(data: [JsonDeserializer], contractId: Int) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            guard let contract = Contract.get(id: contractId, context: context) else {
                print("Failed to save messages: Core data failed to fetch contract")
                return
            }
            
            var maxMessageId: Int = 0
            
            for messageData in data {
                let message = saveFromJson(data: messageData, context: context)
                
                for attachmentData in messageData.attachments {
                    let attachment = Attachment.saveFromJson(data: attachmentData, context: context)
                    if let isExist = message.attachments?.contains(attachment), !isExist {
                        message.addToAttachments(attachment)
                    }
                }
                
                for imageData in messageData.images {
                    let image = ImageAttachment.saveFromJson(data: imageData, context: context)
                    if let isExist = message.images?.contains(image), !isExist {
                        message.addToImages(image)
                        PersistenceController.save(context: context)
                    }
                }
                
                if let isExist = contract.messages?.contains(message), !isExist {
                    contract.addToMessages(message)
                    PersistenceController.save(context: context)
                }
                
                if messageData.id > maxMessageId {
                    maxMessageId = messageData.id
                }
            }
            
            contract.lastFetchedMessage = Message.get(id: maxMessageId, context: context)
            PersistenceController.save(context: context)
        }
    }
}

extension Message.JsonDeserializer {
    func isSimilar(_ message: Message) -> Bool {
        if message.id != Int64(id) ||
            message.text != text ||
            message.sent != sentAsDate ||
            message.deadline != deadlineAsDate ||
            message.isAnswered != isAnswered ||
            message.isOvertime != isOvertime ||
            message.isWarning != isWarning ||
            message.isDoctorMessage != isDoctorMessage ||
            message.author != author ||
            message.authorRole != author_role ||
            message.isAuto != is_auto ||
            message.state != state ||
            message.isAgent != is_agent ||
            message.actionType != action_type ||
            message.actionName != action_name ||
            message.actionDeadline != action_deadline ||
            message.actionOnetime != action_onetime ||
            message.actionUsed != action_used ||
            message.actionBig != action_big ||
            message.forwardToDoctor != forward_to_doctor ||
            message.onlyDoctor != only_doctor ||
            message.onlyPatient != only_patient ||
            message.isUrgent != is_urgent ||
            message.isWarning != is_warning ||
            message.isFiltered != is_filtered {
            return false
        }
            
        if let actionLink = action_link, let urlEncoded = actionLink.urlEncoded, message.actionLink != URL(string: urlEncoded) {
            return false
        }
        if let apiActionLink = api_action_link, let urlEncoded = apiActionLink.urlEncoded, message.apiActionLink != URL(string: urlEncoded) {
            return false
        }
        if let replyToId = reply_to_id, message.replyToId != Int64(replyToId) {
            return false
        }
        return true
    }
}
