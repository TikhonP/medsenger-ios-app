//
//  ClinicScenario+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension ClinicScenario {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var wrappedDescription: String {
        scenarioDescription ?? ""
    }
}

extension ClinicScenario {
    public var systemNameIcon: String {
        "person.2.badge.gearshape"
    }
}
