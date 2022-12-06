//
//  ClinicScenarioParam+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ClinicScenarioParam)
public class ClinicScenarioParam: NSManagedObject {
    internal static func get(code: String, scenario: ClinicScenario, for context: NSManagedObjectContext) -> ClinicScenarioParam? {
        let fetchRequest = ClinicScenarioParam.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "code == %@ AND scenario == %@", code, scenario)
        fetchRequest.fetchLimit = 1
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context)
        return fetchedResults?.first
    }
}
