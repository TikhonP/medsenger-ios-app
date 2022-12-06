//
//  InfoMaterial+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension InfoMaterial {
    public struct JsonDecoder: Decodable {
        let name: String
        let link: URL
    }
    
    private static func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> InfoMaterial {
        let infoMaterial = get(name: data.name, contract: contract, for: context) ?? InfoMaterial(context: context)
        
        infoMaterial.name = data.name
        infoMaterial.link = data.link
        infoMaterial.contract = contract
        
        return infoMaterial
    }
    
    public static func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [InfoMaterial] {
        var gotNames = [String]()
        var infoMaterials = [InfoMaterial]()
        
        for infoMaterialData in data {
            let infoMaterial = saveFromJson(infoMaterialData, contract: contract, for: context)
            
            gotNames.append(infoMaterialData.name)
            infoMaterials.append(infoMaterial)
        }
        
        if !gotNames.isEmpty {
            cleanRemoved(gotNames, contract: contract, for: context)
        }
        
        return infoMaterials
    }
}
