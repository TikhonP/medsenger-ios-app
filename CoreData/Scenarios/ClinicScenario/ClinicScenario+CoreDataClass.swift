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
    public static func getScenariosCategories(clinic: Clinic ) -> [String] {
        let context = PersistenceController.shared.container.viewContext
        
        var scenarios = [ClinicScenario]()
        context.performAndWait {
            let fetchRequest = ClinicScenario.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "clinic == %@", clinic)
            if let fetchedResults = PersistenceController.fetch(fetchRequest, for: context) {
                scenarios = fetchedResults
            }
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
