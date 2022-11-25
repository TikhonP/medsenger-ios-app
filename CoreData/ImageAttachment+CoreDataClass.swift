//
//  ImageAttachment+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(ImageAttachment)
public class ImageAttachment: NSManagedObject {
    private class func get(id: Int, for context: NSManagedObjectContext) -> ImageAttachment? {
        let fetchRequest = ImageAttachment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "ImageAttachment get by id")
        return fetchedResults?.first
    }
}

extension ImageAttachment {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
}

extension ImageAttachment {
    struct JsonSerializer: Decodable {
        let id: Int
        let name: String
        let real: Int
        let small: Int
        let thumb: Int
    }
    
    class func saveFromJson(_ data: JsonSerializer, for context: NSManagedObjectContext) -> ImageAttachment {
        let image = get(id: data.id, for: context) ?? ImageAttachment(context: context)
        
        image.id = Int64(data.id)
        image.name = data.name
        image.real = Int64(data.real)
        image.small = Int64(data.small)
        image.thumb = Int64(data.thumb)
        
        return image
    }
}
