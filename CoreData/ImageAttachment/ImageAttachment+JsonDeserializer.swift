//
//  ImageAttachment+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension ImageAttachment {
    public struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
        let real: Int
        let small: Int
        let thumb: Int
    }
    
    public static func saveFromJson(_ data: JsonDeserializer, for moc: NSManagedObjectContext) -> ImageAttachment {
        let image = (try? get(id: data.id, for: moc)) ?? ImageAttachment(context: moc)
        
        image.id = Int64(data.id)
        image.name = data.name
        image.real = Int64(data.real)
        image.small = Int64(data.small)
        image.thumb = Int64(data.thumb)
        
        return image
    }
}
