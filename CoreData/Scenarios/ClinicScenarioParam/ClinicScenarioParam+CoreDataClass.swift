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
    internal static func get(code: String, scenario: ClinicScenario, for moc: NSManagedObjectContext) throws -> ClinicScenarioParam {
        let fetchRequest = ClinicScenarioParam.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "code == %@ AND scenario == %@", code, scenario)
        fetchRequest.fetchLimit = 1
        let fetchedResults = try moc.wrappedFetch(fetchRequest, detailsForLogging: "ClinicScenarioParam.get")
        guard let clinicScenarioParam = fetchedResults.first else {
            throw PersistenceController.ObjectNotFoundError()
        }
        return clinicScenarioParam
    }
    
    public enum ParamType: String, Decodable {
        case checkbox, select, number, text, date, hidden, currentDate = "current_date", unknown
    }
}
