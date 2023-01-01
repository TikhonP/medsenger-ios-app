//
//  ClinicScenarioParamOption+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ClinicScenarioParamOption)
public class ClinicScenarioParamOption: NSManagedObject {
    internal static func get(code: String, param: ClinicScenarioParam, for moc: NSManagedObjectContext) throws -> ClinicScenarioParamOption {
        let fetchRequest = ClinicScenarioParamOption.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "code == %@ AND param == %@", code, param)
        fetchRequest.fetchLimit = 1
        let fetchedResults = try moc.wrappedFetch(fetchRequest, detailsForLogging: "ClinicScenarioParamOption.get")
        guard let clinicScenarioParamOption = fetchedResults.first else {
            throw PersistenceController.ObjectNotFoundError()
        }
        return clinicScenarioParamOption
    }
}
