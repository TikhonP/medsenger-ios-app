//
//  InfoMaterial+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(InfoMaterial)
public class InfoMaterial: NSManagedObject {
    private class func get(name: String, contract: Contract, context: NSManagedObjectContext) -> InfoMaterial? {
        do {
            let fetchRequest = InfoMaterial.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
            let fetchedResults = try context.fetch(fetchRequest)
            if let infoMaterial = fetchedResults.first {
                return infoMaterial
            }
            return nil
        } catch {
            print("Fetch `InfoMaterial` core data failed: \(error.localizedDescription)")
            return nil
        }
    }
}

extension InfoMaterial {
    struct JsonDecoder: Decodable {
        let name: String
        let link: URL
    }
    
    private class func cleanRemoved(validNames: [String], contract: Contract, context: NSManagedObjectContext) {
        do {
            let fetchRequest = InfoMaterial.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for infoMaterial in fetchedResults {
                if let name = infoMaterial.name, !validNames.contains(name) {
                    context.delete(infoMaterial)
                    PersistenceController.save(context: context)
                }
            }
        } catch {
            print("Fetch `InfoMaterial` core data failed: \(error.localizedDescription)")
        }
    }
    
    private class func saveFromJson(data: JsonDecoder, contract: Contract, context: NSManagedObjectContext) -> InfoMaterial {
        let infoMaterial = {
            guard let infoMaterial = get(name: data.name, contract: contract, context: context) else {
                return InfoMaterial(context: context)
            }
            return infoMaterial
        }()
        
        infoMaterial.name = data.name
        infoMaterial.link = data.link
        
        PersistenceController.save(context: context)
        
        return infoMaterial
    }
    
    class func saveFromJson(data: [JsonDecoder], contract: Contract, context: NSManagedObjectContext) -> [InfoMaterial] {
        var gotNames = [String]()
        var infoMaterials = [InfoMaterial]()
        
        for infoMaterialData in data {
            let infoMaterial = saveFromJson(data: infoMaterialData, contract: contract, context: context)
            
            gotNames.append(infoMaterialData.name)
            infoMaterials.append(infoMaterial)
        }
        
        if !gotNames.isEmpty {
            cleanRemoved(validNames: gotNames, contract: contract, context: context)
        }
        
        return infoMaterials
    }
}
