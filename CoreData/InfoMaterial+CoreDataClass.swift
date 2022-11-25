//
//  InfoMaterial+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(InfoMaterial)
public class InfoMaterial: NSManagedObject {
    private class func get(name: String, contract: Contract, for context: NSManagedObjectContext) -> InfoMaterial? {
        let fetchRequest = InfoMaterial.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ && contract = %@", name, contract)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "InfoMaterial get by name and contract")
        return fetchedResults?.first
    }
}

extension InfoMaterial {
    struct JsonDecoder: Decodable {
        let name: String
        let link: URL
    }
    
    private class func cleanRemoved(validNames: [String], contract: Contract, for context: NSManagedObjectContext) {
        let fetchRequest = InfoMaterial.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "InfoMaterial fetch by contract for removing") else {
            return
        }
        for infoMaterial in fetchedResults {
            if let name = infoMaterial.name, !validNames.contains(name) {
                context.delete(infoMaterial)
            }
        }
    }
    
    private class func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> InfoMaterial {
        let infoMaterial = get(name: data.name, contract: contract, for: context) ?? InfoMaterial(context: context)
        
        infoMaterial.name = data.name
        infoMaterial.link = data.link
        infoMaterial.contract = contract
        
        return infoMaterial
    }
    
    class func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [InfoMaterial] {
        var gotNames = [String]()
        var infoMaterials = [InfoMaterial]()
        
        for infoMaterialData in data {
            let infoMaterial = saveFromJson(infoMaterialData, contract: contract, for: context)
            
            gotNames.append(infoMaterialData.name)
            infoMaterials.append(infoMaterial)
        }
        
        if !gotNames.isEmpty {
            cleanRemoved(validNames: gotNames, contract: contract, for: context)
        }
        
        return infoMaterials
    }
}
