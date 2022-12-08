//
//  ScenarioViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class ScenarioViewModel: ObservableObject {
    @Published var paramsAsNodes = [ClinicScenarioParamNode]()
    @Published var showSaveLoading = false
    
    @Published var invalidFieldName: String = ""
    @Published var showInvalidFieldsAlert = false
    
    private let scenarioId: Int
    private let contractId: Int
    
    init(scenario: ClinicScenario, contractId: Int) {
        self.scenarioId = Int(scenario.id)
        self.contractId = contractId
        for param in scenario.paramsArray {
            paramsAsNodes.append(ClinicScenarioParamNode(param))
        }
    }
    
    private func validateFields() -> Bool {
        for param in paramsAsNodes {
            if !param.isValid {
                invalidFieldName = param.name
                return false
            }
        }
        return true
    }
    
    func save(completion: @escaping () -> Void) {
        guard validateFields() else {
            showInvalidFieldsAlert = true
            return
        }
        showSaveLoading = true
        DoctorActions.shared.addScenario(contractId: contractId, scenarioId: scenarioId, params: paramsAsNodes) { [weak self] succeeded in
            DispatchQueue.main.async {
                self?.showSaveLoading = false
                if succeeded {
                    completion()
                }
            }
        }
    }
}
