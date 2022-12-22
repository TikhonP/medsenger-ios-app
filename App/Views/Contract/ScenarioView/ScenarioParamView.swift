//
//  ScenarioParamView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ScenarioParamView: View {
    @ObservedObject var param: ClinicScenarioParamNode
    
    var body: some View {
        if param.type == .number || param.type == .text {
            Section(header: Text(param.name), footer: Text(param.description)) {
                if param.type == .number {
                    TextField("ScenarioParamView.enterNumberHere.TextField", text: $param.value)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.numberPad)
                } else if param.type == .text {
                    TextField("ScenarioParamView.EnterTextHere.TextField", text: $param.value)
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

//struct ScenarioParamView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScenarioParamView()
//    }
//}
