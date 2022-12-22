//
//  AddContractViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

enum Sex: String, Codable, CaseIterable {
    case male, female
}

final class AddContractViewModel: ObservableObject, Alertable {
    enum AddContractViewStates {
        case inputClinicAndEmail
        case fetchingUserFromMedsenger
        case knownClient, unknownClient
    }
    
    @Published var alert: AlertInfo?
    
    @Published var clinicId: Int = {
        if let clinic = Clinic.objectsAll().first {
            return Int(clinic.id)
        } else {
            return 1
        }
    }()
    @Published var clinic: Clinic?
    @Published var patientEmail = ""
    @Published var state: AddContractViewStates = .inputClinicAndEmail
    
    @Published var patientName = ""
    @Published var patientBirthday = Date()
    @Published var patientSex: Sex = .male
    @Published var patientPhone = ""
    
    @Published var contractNumber = ""
    @Published var contractEndDate = Date()
    @Published var clinicRuleId: Int = 0
    @Published var clinicClassifierId: Int = 0
    @Published var videoEnabled = false
    
    @Published var submittingAddPatient = false
    
    private var userExists: Bool?
    
    private let welcomeMessage = "" // FIXME: !!!
    
    func findPatient() {
        guard !patientEmail.isEmpty else {
            presentAlert(
                title: Text("AddContractViewModel.emailIsEmptyAlertTitle", comment: "Email is empty!"),
                message: Text("AddContractViewModel.emailIsEmptyMessage", comment: "Please fill the email field."), .warning)
            return
        }
        guard patientEmail.isEmail() else {
            presentAlert(
                title: Text("AddContractViewModel.invalidEmailAlertTitle", comment: "Invalid patient email!"),
                message: Text("AddContractViewModel.invalidEmailAlertMessage", comment: "Please check patient email to continue."), .warning)
            return
        }
        state = .fetchingUserFromMedsenger
        clinic = Clinic.get(id: clinicId)
        if let rule = clinic?.rulesArray.first {
            clinicRuleId = Int(rule.id)
        }
        if let classifier = clinic?.classifiersArray.first {
            clinicClassifierId = Int(classifier.id)
        }
        DoctorActions.shared.findUser(clinicId: clinicId, email: patientEmail, completion: { [weak self] data, contractExists in
            DispatchQueue.main.async {
                if contractExists {
                    self?.presentAlert(
                        title: Text("AddContractViewModel.contractAlreadyExistsAlertTitle", comment: "Contract already exists"),
                        message: Text("AddContractViewModel.contractAlreadyExistsAlertMessage", comment: "Please check email. Contract with provided email already exists."), .warning)
                    self?.state = .inputClinicAndEmail
                } else if let data = data {
                    self?.userExists = data.found
                    self?.patientName = ""
                    self?.patientBirthday = Date()
                    if data.found {
                        self?.state = .knownClient
                        if let name = data.name, let birthday = data.birthday {
                            self?.patientName = name
                            self?.patientBirthday = birthday
                        }
                    } else {
                        self?.state = .unknownClient
                    }
                } else {
                    self?.state = .inputClinicAndEmail
                    self?.presentGlobalAlert()
                }
            }
        })
    }
    
    func addContract(completion: @escaping () -> Void) {
        guard !patientName.isEmpty else {
            presentAlert(
                title: Text("AddContractViewModel.nameIsEmptyAlertTitle", comment: "Patient name cannot be empty!"),
                message: Text("AddContractViewModel.nameIsEmptyAlertMessage", comment: "Please provide a name to continue."), .warning)
            return
        }
        guard contractEndDate > Date() else {
            presentAlert(
                title: Text("AddContractViewModel.contractAndDateAreOlderThanNowAlertTitle", comment: "Contract end date are older than now!"),
                message: Text("AddContractViewModel.contractAndDateAreOlderThanNowAlertMessage", comment: "Please check contract end date and correct it."), .warning)
            return
        }
        guard let userExists = userExists else {
            return
        }
        submittingAddPatient = true
        let addContractRequestModel = AddContractRequestModel(
            clinic: clinicId,
            email: patientEmail,
            exists: userExists,
            birthday: patientBirthday,
            name: patientName,
            sex: patientSex,
            phone: patientPhone,
            endDate: contractEndDate,
            rule: String(clinicRuleId),
            classifier: String(clinicClassifierId),
            welcomeMessage: welcomeMessage,
            video: videoEnabled,
            number: contractNumber)
        DoctorActions.shared.addContract(addContractRequestModel) { [weak self] succeeded in
            DispatchQueue.main.async {
                self?.submittingAddPatient = false
                if succeeded {
                    ChatsViewModel.shared.getContracts(presentFailedAlert: false)
                    completion()
                } else {
                    self?.presentGlobalAlert()
                }
            }
        }
    }
}
