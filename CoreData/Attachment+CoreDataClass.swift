//
//  Attachment+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(Attachment)
public class Attachment: NSManagedObject {
    struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
        let icon: String
        let mime: String
        let size: Int
    }
    
    class func getAttachment(id: Int, context: NSManagedObjectContext) -> Attachment? {
        do {
            let fetchRequest = Attachment.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            let fetchedResults = try context.fetch(fetchRequest)
            if let attachment = fetchedResults.first {
                return attachment
            }
            return nil
        }
        catch {
            print("Fetch core data task failed: ", error.localizedDescription)
            return nil
        }
    }
    
    class func saveFromJson(data: JsonDeserializer, context: NSManagedObjectContext) -> Attachment {
        let attachment = {
            if let attachment = getAttachment(id: data.id, context: context) {
                return attachment
            } else {
                return Attachment(context: context)
            }
        }()
        
        attachment.id = Int64(data.id)
        attachment.name = data.name
        attachment.icon = data.icon
        attachment.mime = data.mime
        attachment.size = Int64(data.size)
        
        PersistenceController.save(context: context)
        
        return attachment
    }
}
