//
//  Attachment+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData
import os.log

@objc(Attachment)
public class Attachment: NSManagedObject {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Attachment.self)
    )
    
    enum Icon: String {
        case word, link, excel, powerpoint, pdf, zip, defaultFile
    }
    
    var iconAsSystemImageName: String {
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
    
    private class func get(id: Int, for context: NSManagedObjectContext) -> Attachment? {
        let fetchRequest = Attachment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "Attachment get by id")
        return fetchedResults?.first
    }
    
    class func writeToFile(_ data: Data, fileName: String) -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            Attachment.logger.error("FileManager.default.urls directory is nil")
            return nil
        }
        let fileurl = directory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileurl.path) {
            if let fileHandle = FileHandle(forWritingAtPath: fileurl.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
                return fileurl
            } else {
                Attachment.logger.error("Error Write attachment to file: Can't open file to write.")
                return nil
            }
        } else {
            do {
                try data.write(to: fileurl, options: .atomic)
                return fileurl
            } catch {
                Attachment.logger.error("Error Write attachment to file: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    class func saveFile(id: Int, data: Data) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let attachment = get(id: id, for: context)
            guard let fileName = attachment?.name else { return }
            attachment?.dataPath = writeToFile(data, fileName: fileName)
            PersistenceController.save(for: context, detailsForLogging: "Attachment save file")
        }
    }
    
    class func get(id: Int) -> Attachment? {
        let context = PersistenceController.shared.container.viewContext
        var attachment: Attachment?
        context.performAndWait {
            attachment = get(id: id, for: context)
        }
        return attachment
    }
}

extension Attachment {
    struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
        let icon: String
        let mime: String
        let size: Int
    }
    
    class func saveFromJson(_ data: JsonDeserializer, for context: NSManagedObjectContext) -> Attachment {
        let attachment = get(id: data.id, for: context) ?? Attachment(context: context)
        
        attachment.id = Int64(data.id)
        attachment.name = data.name
        attachment.icon = data.icon
        attachment.mime = data.mime
        attachment.size = Int64(data.size)
        
        return attachment
    }
}
