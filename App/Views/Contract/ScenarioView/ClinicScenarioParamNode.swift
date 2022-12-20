//
//  ClinicScenarioParamNode.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class ClinicScenarioParamNode: ObservableObject, Identifiable {
    @Published var value: String
    @Published var toggleValue: Bool = false
    @Published var dateValue: Date = Date()
    
    let id = UUID()
    let name: String
    let description: String
    let required: Bool
    let code: String
    let type: ClinicScenarioParam.ParamType
    
    var pickerOptions = [ClinicScenarioParamOption]()
    
    init(_ param: ClinicScenarioParam) {
        self.type = param.wrappedType
        if self.type == .hidden {
            self.value = param.wrappedValue
        } else {
            self.value = param.wrappedDefaultValue
            if self.type == .checkbox {
                if let toggleValue = Bool(param.wrappedDefaultValue) {
                    self.toggleValue = toggleValue
                }
            } else if self.type == .date {
                // print("Date value: \(param.wrappedDefaultValue)")
            } else if self.type == .select {
                self.pickerOptions = param.optionsArray
                self.value = param.defaultOtionCode
            }
        }
        self.name = param.wrappedName
        self.description = param.wrappedDescription
        self.required = param.required
        self.code = param.wrappedCode
    }
    
    var isPresentable: Bool {
        type != .hidden && type != .currentDate
    }
    
    var isValid: Bool {
        switch type {
        case .checkbox:
            return true
        case .select:
            return (pickerOptions.map { $0.code }.contains(value)) || !required
        case .number:
            return Int(value) != nil || !required
        case .text:
            return !value.isEmpty || !required
        case .date:
            return true
        case .hidden:
            return true
        case .currentDate:
            return true
        case .unknown:
            return true
        }
    }
}
