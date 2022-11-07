//
//  Message+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
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
        let is_auto: Bool
        let state: String
        let is_agent: Bool
        let action_type: String
        let action_link: String?
        let api_action_link: String?
        let action_name: String?
        let action_deadline: Date
        let action_onetime: Bool
        let action_used: Bool
        let action_big: Bool
        let forward_to_doctor: Bool
        let only_doctor: Bool
        let only_patient: Bool
        let is_urgent: Bool
        let is_warning: Bool
        let is_filtered: Bool
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
    
    private class func getMessage(id: Int, context: NSManagedObjectContext) -> Message? {
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
    
    private class func saveMessageFromJson(data: JsonDeserializer, context: NSManagedObjectContext) -> Message {
        let message = {
            if let message = getMessage(id: data.id, context: context) {
                return message
            } else {
                return Message(context: context)
            }
        }()
        
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
        message.isAuto = data.is_auto
        message.state = data.state
        message.isAgent = data.is_agent
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
        message.actionUsed = data.action_used
        message.actionBig = data.action_big
        message.forwardToDoctor = data.forward_to_doctor
        message.onlyDoctor = data.only_doctor
        message.onlyPatient = data.only_patient
        message.isUrgent = data.is_urgent
        message.isWarning = data.is_warning
        message.isFiltered = data.is_filtered
        
        if let replyToId = data.reply_to_id {
            message.replyToId = Int64(replyToId)
        }
        
        PersistenceController.save(context: context)
        
        return message
    }
    
    class func saveMessagesFromJson(data: [JsonDeserializer], contractId: Int) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            guard let contract = UserDoctorContract.getContract(contractId: contractId, context: context) else {
                print("Failed to save messages: Core data failed to fetch contract")
                return
            }
            
            for messageData in data {
                let message = saveMessageFromJson(data: messageData, context: context)
                
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
                    }
                }
                
                if let isExist = contract.messages?.contains(message), !isExist {
                    contract.addToMessages(message)
                }
                
                PersistenceController.save(context: context)
            }
        }
    }
}
