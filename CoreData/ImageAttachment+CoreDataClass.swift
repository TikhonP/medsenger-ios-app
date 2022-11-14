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
    struct JsonSerializer: Decodable {
        let id: Int
        let name: String
        let real: Int
        let small: Int
        let thumb: Int
    }
    
    private class func getImage(id: Int, context: NSManagedObjectContext) -> ImageAttachment? {
        do {
            let fetchRequest = ImageAttachment.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            let fetchedResults = try context.fetch(fetchRequest)
            if let imageAttachment = fetchedResults.first {
                return imageAttachment
            }
            return nil
        }
        catch {
            print("Fetch core data task failed: ", error.localizedDescription)
            return nil
        }
    }
    
    class func saveFromJson(data: JsonSerializer, context: NSManagedObjectContext) -> ImageAttachment {
        let image = {
            if let image = getImage(id: data.id, context: context) {
                return image
            } else {
                return ImageAttachment(context: context)
            }
        }()
        
        image.id = Int64(data.id)
        image.name = data.name
        image.real = Int64(data.real)
        image.small = Int64(data.small)
        image.thumb = Int64(data.thumb)
        
        PersistenceController.save(context: context)
        
        return image
    }
}
