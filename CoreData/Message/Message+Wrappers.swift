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
        text ?? "Unknown text"
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
            return !isDoctorMessage && !onlyDoctor
        case .doctor:
            return isDoctorMessage && !onlyPatient
        case .unknown:
            return true
        }
    }
    
    public var isVoiceMessage: Bool {
        // FIXME: !!!
        text == Constants.voiceMessageText && attachmentsArray.count == 1
    }
}
