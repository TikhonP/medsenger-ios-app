//
//  ScenarioViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class ScenarioViewModel: ObservableObject, Alertable {
    @Published var paramsAsNodes = [ClinicScenarioParamNode]()
    @Published var showSaveLoading = false
    
    @Published var invalidFieldName: String = ""
    @Published var alert: AlertInfo?
    
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
    
    enum ScenarioViewModelError: Error {
        case invalidFieldAlertTitle
        case requestFailed(_ error: Error)
    }
    
    func save() async throws {
        guard validateFields() else {
            presentAlert(title: Text("ScenarioViewModel.invalidFieldAlertTitle", comment: "Invalid field"), message: Text(invalidFieldName))
            throw ScenarioViewModelError.invalidFieldAlertTitle
        }
        showSaveLoading = true
        do {
            try await DoctorActions.addScenario(contractId: contractId, scenarioId: scenarioId, params: paramsAsNodes)
            showSaveLoading = false
        } catch {
            showSaveLoading = false
            throw ScenarioViewModelError.requestFailed(error)
        }
    }
}
