//
//  Message+Preview.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension Message {
    static func getSampleMessage(for viewContext: NSManagedObjectContext, id: Int = Int.random(in: 0...10000)) -> Message {
        let message = Message(context: viewContext)
        
        message.id = Int64(id)
        message.text = "Мы запросили доступ к данным глюкометра FreeStyle Libre. Пожалуйста, проверьте электронную почту и предоставьте доступ. После этого Ваш врач сможет автоматически получать отчеты об уровне глюкозы."
        message.sent = Date()
        message.deadline = Date()
        message.isAnswered = false
        message.isOvertime = false
        message.isWarning = false
        message.isDoctorMessage = false
        message.author = "data.author"
        message.authorRole = "data.author_role"
//        if let isAuto = data.is_auto {
//            message.isAuto = isAuto
//        }
        message.state = ""
//        if let isAgent = data.is_agent {
//            message.isAgent = isAgent
//        }
        message.actionType = "data.action_type"
//        if let actionLink = data.action_link, let urlEncoded = actionLink.urlEncoded {
//            message.actionLink = URL(string: urlEncoded)
//        }
//        if let apiActionLink = data.api_action_link, let urlEncoded = apiActionLink.urlEncoded {
//            message.apiActionLink = URL(string: urlEncoded)
//        }
        message.actionName = "data.action_name"
        message.actionDeadline = Date()
        message.actionOnetime = false
//        if let actionUsed = data.action_used {
//            message.actionUsed = actionUsed
//        }
        message.actionBig = false
        message.forwardToDoctor = false
        message.onlyDoctor = false
        message.onlyPatient = false
        message.isUrgent = false
        message.isWarning = false
//        if let isFiltered = data.is_filtered {
//            message.isFiltered = isFiltered
//        }
//
//        if let replyToId = data.reply_to_id {
//            message.replyToId = Int64(replyToId)
//        }
//
        return message
    }
}
