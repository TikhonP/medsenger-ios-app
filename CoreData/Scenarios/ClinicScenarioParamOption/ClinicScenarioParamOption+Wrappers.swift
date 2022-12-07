//
//  ClinicScenarioParamOption+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension ClinicScenarioParamOption {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var wrappedCode: String {
        code ?? "Unknown code"
    }
}
