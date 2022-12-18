//
//  Message+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension Message {
    public var wrappedText: String {
        text ?? ""
    }
    
    public var wrappedActionName: String {
        actionName ?? "Unknown action name"
    }
    
    public var wrappedActionType: ActionType? {
        guard let actionType = actionType else {
            return nil
        }
        return ActionType(rawValue: actionType)
    }
    
    public var wrappedAuthor: String {
        author ?? "Unknown author"
    }
    
    public var wrappedAuthorRole: String {
        authorRole ?? "Unknown role"
    }
    
    public var attachmentsArray: [Attachment] {
        let set = attachments as? Set<Attachment> ?? []
        return Array(set)
    }
    
    public var imagesArray: [ImageAttachment] {
        let set = images as? Set<ImageAttachment> ?? []
        return Array(set)
    }
}

extension Message {
    public var isMessageSent: Bool {
        switch UserDefaults.userRole {
        case .patient:
            return !isDoctorMessage
        case .doctor:
            return isDoctorMessage
        case .unknown:
            return true
        }
    }
    
    public var isActionDeadlined: Bool {
        guard isAgent, let actionDeadline = actionDeadline else {
            return false
        }
        return Date() > actionDeadline
    }
    
    public var showMessage: Bool {
        let allowedRole = {
            switch UserDefaults.userRole {
            case .patient:
                return !onlyDoctor
            case .doctor:
                return !onlyPatient
            case .unknown:
                return true
            }
        }()
        
        let isUsedOrDeadlinedAction = {
            isAgent && (actionUsed || isActionDeadlined)
        }()
        
        return allowedRole && !isUsedOrDeadlinedAction
    }
    
    public var isVoiceMessage: Bool {
        // FIXME: !!!
        text == Constants.voiceMessageText && attachmentsArray.count == 1
    }
    
    public var isVideoCallMessageFromDoctor: Bool {
        !isAgent && isAuto
    }
}
