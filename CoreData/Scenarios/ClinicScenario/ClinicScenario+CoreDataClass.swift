//
//  ClinicScenario+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ClinicScenario)
public class ClinicScenario: NSManagedObject, CoreDataIdGetable {
    public static func getScenariosCategories(clinic: Clinic) async throws -> [String] {
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        let scenarios = try await context.crossVersionPerform {
            let fetchRequest = ClinicScenario.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "clinic == %@", clinic)
            return try context.fetch(fetchRequest)
        }
        
        var categories: Set<String> = []
        for scenario in scenarios {
            if let category = scenario.category {
                categories.insert(category)
            }
        }
        
        return Array(categories)
    }
}
