//
//  Attachment+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension Attachment {
    public struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
        let icon: String
        let mime: String
        let size: Int
    }
    
    public static func saveFromJson(_ data: JsonDeserializer, for context: NSManagedObjectContext) -> Attachment {
        let attachment = get(id: data.id, for: context) ?? Attachment(context: context)
        
        attachment.id = Int64(data.id)
        attachment.name = data.name
        attachment.icon = data.icon
        attachment.mime = data.mime
        attachment.size = Int64(data.size)
        
        return attachment
    }
}
