//
//  ClinicClassifier+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension ClinicClassifier {
    public struct JsonDeserializer: Decodable {
        let id: Int
        let name: String
    }
    
    public static func saveFromJson(_ data: JsonDeserializer, for moc: NSManagedObjectContext) -> ClinicClassifier {
        let clinicClassifier = (try? get(id: data.id, for: moc)) ?? ClinicClassifier(context: moc)
        
        clinicClassifier.id = Int64(data.id)
        clinicClassifier.name = data.name
        
        return clinicClassifier
    }
}
