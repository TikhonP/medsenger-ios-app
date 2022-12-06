//
//  Attachment+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension Attachment {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
}

extension Attachment {
    public enum Icon: String {
        case word, link, excel, powerpoint, pdf, zip, defaultFile
    }
    
    public var iconAsSystemImageName: String {
        guard let iconName = icon else { return "doc.fill" }
        let icon = Icon(rawValue: iconName) ?? .defaultFile
        switch icon {
        case .word:
            return "doc.text.fill"
        case .link:
            return "link.circle.fill"
        case .excel:
            return "tablecells.fill"
        case .powerpoint:
            return "note"
        case .pdf:
            return "doc.richtext"
        case .zip:
            return "doc.zipper"
        case .defaultFile:
            return "doc.fill"
        }
    }
    
    public var dataPath: URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            Attachment.logger.error("FileManager.default.urls directory is nil")
            return nil
        }
        guard let localFileName = localFileName else {
            return nil
        }
        return URL(fileURLWithPath: localFileName, relativeTo: directory)
    }
}
