//
//  ChatViewAttachment.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers
import os.log

class ChatViewAttachment: Identifiable, Equatable {
    enum ChatViewAttachmentType: String {
        case image, video, audio, file
    }
    
    static func == (lhs: ChatViewAttachment, rhs: ChatViewAttachment) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    let data: Data
    let extention: String
    let realFilename: String?
    let type: ChatViewAttachmentType
    
    init(data: Data, extention: String, realFilename: String?, type: ChatViewAttachmentType) {
        self.data = data
        self.extention = extention
        self.realFilename = realFilename
        self.type = type
    }
    
    private var savedUrl: URL?
    
    var mimeType: String {
        if let mimeType = UTType(filenameExtension: extention)?.preferredMIMEType {
            return mimeType
        } else {
            return "multipart/form-data"
        }
    }
    
    var randomFilename: String {
        let url = URL(fileURLWithPath: String.uniqueFilename(), relativeTo: nil)
        let fileURL = url.appendingPathExtension(extention)
        return fileURL.relativePath
    }
    
    var filename: String {
        realFilename ?? randomFilename
    }
    
    func saveToFile() -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return nil
        }
        let fileUrl = URL(fileURLWithPath: String.uniqueFilename(), relativeTo: directory).appendingPathExtension(extention)
        savedUrl = fileUrl
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            if let fileHandle = FileHandle(forWritingAtPath: fileUrl.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
                return fileUrl
            } else {
                return nil
            }
        } else {
            do {
                try data.write(to: fileUrl, options: .atomic)
                return fileUrl
            } catch {
                return nil
            }
        }
    }
    
    deinit {
        if let fileUrl = savedUrl {
            do {
                try FileManager.default.removeItem(at: fileUrl)
            } catch {
                Logger.defaultLogger.error("Failed to remove file preview: \(error.localizedDescription)")
            }
        }
    }
}
