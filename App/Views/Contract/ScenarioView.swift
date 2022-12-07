//
//  ScenarioView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

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
                print("Date value: \(param.wrappedDefaultValue)")
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
}

final class ScenarioViewModel: ObservableObject {
    @Published var paramsAsNodes = [ClinicScenarioParamNode]()
    
    private let scenario: ClinicScenario
    
    init(scenario: ClinicScenario) {
        self.scenario = scenario
        for param in scenario.paramsArray {
            paramsAsNodes.append(ClinicScenarioParamNode(param))
        }
    }
}

struct ScenarioParamView: View {
    @ObservedObject var param: ClinicScenarioParamNode
    
    var body: some View {
        if param.type == .number || param.type == .text {
            Section(header: Text(param.name), footer: Text(param.description)) {
                if param.type == .number {
                    TextField("Enter number here", text: $param.value)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.numberPad)
                } else if param.type == .text {
                    TextField("Enter text here", text: $param.value)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
        } else if param.type == .checkbox {
            Section(footer: Text(param.description)) {
                Toggle(param.name, isOn: $param.toggleValue)
            }
        } else if param.type == .date {
            Section(footer: Text(param.description)) {
                DatePicker(param.name, selection: $param.dateValue, displayedComponents: [.date])
            }
        } else if param.type == .select {
            Section(footer: Text(param.description)) {
                Picker(param.name, selection: $param.value) {
                    ForEach(param.pickerOptions) { option in
                        Text(option.wrappedName).tag(option.wrappedCode)
                    }
                }
            }
        }
    }
}

struct ScenarioView: View {
    @ObservedObject var scenario: ClinicScenario
    
    @StateObject private var scenarioViewModel: ScenarioViewModel
    
    init(scenario: ClinicScenario) {
        self.scenario = scenario
        _scenarioViewModel = StateObject(wrappedValue: ScenarioViewModel(scenario: scenario))
    }
    
    var body: some View {
        Form {
            if !scenario.wrappedDescription.isEmpty {
                Section {
                    Text(scenario.wrappedDescription)
                }
            }
            
            ForEach(scenarioViewModel.paramsAsNodes) { param in
                if param.isPresentable {
                    ScenarioParamView(param: param)
                }
            }
            
            Button("Select this scenario") {
                
            }
        }
        .deprecatedScrollDismissesKeyboard()
        .navigationTitle(scenario.wrappedName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//
//struct ScenarioView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScenarioView()
//    }
//}
