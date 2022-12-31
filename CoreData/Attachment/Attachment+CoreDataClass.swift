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
public class Attachment: NSManagedObject, CoreDataIdGetable {
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Attachment.self)
    )
    
    func saveFile(_ data: Data) {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            Attachment.logger.error("FileManager.default.urls directory is nil")
            return
        }
        let fileUrl: URL
        if let dataPath = dataPath {
            fileUrl = dataPath
        } else {
            guard let fileName = name else {
                return
            }
            let extention = URL(fileURLWithPath: fileName, relativeTo: nil).pathExtension
            fileUrl = URL(fileURLWithPath: String.uniqueFilename(), relativeTo: directory).appendingPathExtension(extention)
        }
        localFileName = Attachment.writeData(data, fileUrl: fileUrl)?.relativePath
    }
    
    private static func writeData(_ data: Data, fileUrl: URL) -> URL? {
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            if let fileHandle = FileHandle(forWritingAtPath: fileUrl.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
                return fileUrl
            } else {
                Attachment.logger.error("Error Write attachment to file: Can't open file to write.")
                return nil
            }
        } else {
            do {
                try data.write(to: fileUrl, options: .atomic)
                return fileUrl
            } catch {
                Attachment.logger.error("Error Write attachment to file: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    struct NoDataPathError: Error { }
    
    public static func saveFile(id: Int, data: Data) async throws -> URL {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return try await context.crossVersionPerform {
            let attachment = try get(id: id, for: context)
            attachment.saveFile(data)
            PersistenceController.save(for: context, detailsForLogging: "Attachment save file")
            guard let dataPath = attachment.dataPath else {
                throw NoDataPathError()
            }
            return dataPath
        }
    }
}
