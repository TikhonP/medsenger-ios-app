//
//  ImageAttachment+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData
import os.log

@objc(ImageAttachment)
public class ImageAttachment: NSManagedObject, CoreDataIdGetable {
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ImageAttachment.self)
    )
    
    private func saveFile(_ data: Data) {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            ImageAttachment.logger.error("FileManager.default.urls directory is nil")
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
        localFileName = ImageAttachment.writeData(data, fileUrl: fileUrl)?.relativePath
    }
    
    private static func writeData(_ data: Data, fileUrl: URL) -> URL? {
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            if let fileHandle = FileHandle(forWritingAtPath: fileUrl.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
                return fileUrl
            } else {
                ImageAttachment.logger.error("Error Write attachment to file: Can't open file to write.")
                return nil
            }
        } else {
            do {
                try data.write(to: fileUrl, options: .atomic)
                return fileUrl
            } catch {
                ImageAttachment.logger.error("Error Write attachment to file: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    public static func saveFile(id: Int, data: Data) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let imageAttachment = get(id: id, for: context)
            imageAttachment?.saveFile(data)
            PersistenceController.save(for: context, detailsForLogging: "ImageAttachment save file")
        }
    }
}
