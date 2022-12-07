//
//  ClinicScenarioParam+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension ClinicScenarioParam {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var wrappedDescription: String {
        paramDescription ?? "Unknown description"
    }
    
    public var wrappedType: ParamType {
        guard let type = type else {
            return .unknown
        }
        return ParamType(rawValue: type) ?? .unknown
    }
    
    public var wrappedValue: String {
        value ?? "Unknown value"
    }
    
    public var wrappedDefaultValue: String {
        defaultValue ?? ""
    }
    
    public var wrappedCode: String {
        code ?? "Unknown code"
    }
    
    public var optionsArray: [ClinicScenarioParamOption] {
        let set = options as? Set<ClinicScenarioParamOption> ?? []
        return Array(set)
    }
}

extension ClinicScenarioParam {
    public var defaultOtionCode: String {
        for option in optionsArray {
            if option.defaultValue {
                return option.wrappedCode
            }
        }
        return optionsArray.first?.wrappedCode ?? "Unknown default value"
    }
}
