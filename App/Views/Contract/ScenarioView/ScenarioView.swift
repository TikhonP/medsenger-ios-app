//
//  ScenarioView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ScenarioView: View {
    @ObservedObject var scenario: ClinicScenario
    @StateObject private var scenarioViewModel: ScenarioViewModel
    @EnvironmentObject private var contractViewModel: ContractViewModel
    
    init(scenario: ClinicScenario, contractId: Int) {
        self.scenario = scenario
        _scenarioViewModel = StateObject(wrappedValue: ScenarioViewModel(scenario: scenario, contractId: contractId))
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
            
            Button(action: {
                scenarioViewModel.save {
                    contractViewModel.showChooseScenario = false
                }
            }, label: {
                if scenarioViewModel.showSaveLoading {
                    ProgressView()
                } else {
                    Text("Select this scenario")
                }
            })
        }
        .deprecatedScrollDismissesKeyboard()
        .navigationTitle(scenario.wrappedName)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $scenarioViewModel.showInvalidFieldsAlert, content: {
            Alert(title: Text("Invalid field"), message: Text(scenarioViewModel.invalidFieldName))
        })
    }
}

//
//struct ScenarioView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScenarioView()
//    }
//}
