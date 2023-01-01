//
//  Clinic+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension Clinic {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var contractsArray: [Contract] {
        let set = contracts as? Set<Contract> ?? []
        return Array(set)
    }
    
    public var agentsArray: [Agent] {
        let set = agents as? Set<Agent> ?? []
        return Array(set)
    }
    
    public var rulesArray: [ClinicRule] {
        let set = rules as? Set<ClinicRule> ?? []
        return Array(set)
    }
    
    public var classifiersArray: [ClinicClassifier] {
        let set = classifiers as? Set<ClinicClassifier> ?? []
        return Array(set)
    }
    
    public var scenariosArray: [ClinicScenario] {
        let set = scenarios as? Set<ClinicScenario> ?? []
        return Array(set)
    }
    
    /// Be careful! It returns entity which can be used only on main thread.
    @MainActor public var devices: [Agent] {
        let viewContext = PersistenceController.shared.container.viewContext
        var result = [Agent]()
        viewContext.performAndWait {
            let fetchRequest = Agent.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "clinics CONTAINS %@ AND isDevice == YES", self)
            if let fetchedResults = try? viewContext.wrappedFetch(fetchRequest, detailsForLogging: "Clinic.hasDevices") {
                result = fetchedResults
            }
        }
        return result
    }
}
