//
//  AddContractViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

enum AddContractViewStates {
    case inputClinicAndEmail
    case fetchingUserFromMedsenger
    case knownClient, unknownClient
}

enum Sex: String, Codable, CaseIterable {
    case male, female
}

fileprivate class AddContractAlerts {
    static let invalidEmailAlert = AlertInfo(
        title: LocalizedStringKey("Invalid patient email!").stringValue(),
        message: "Please check patient email to continue.")
    static let emailIsEmpty = AlertInfo(
        title: LocalizedStringKey("Invalid patient email!").stringValue(),
        message: "Please provide patient email to continue.")
    static let contractExistsAlert = AlertInfo(
        title: LocalizedStringKey("Contract already exists").stringValue(),
        message: LocalizedStringKey("Please check email. Contract with provided email already exists.").stringValue())
    static let nameIsEmpty = AlertInfo(
        title: LocalizedStringKey("Patient name cannot be empty!").stringValue(),
        message: LocalizedStringKey("Please provide a name to continue.").stringValue())
    static let contractDateAreOlderThanNow = AlertInfo(
        title: LocalizedStringKey("Contract end date are older than now!").stringValue(),
        message: LocalizedStringKey("Please check contract end date and correct it.").stringValue())
}

final class AddContractViewModel: ObservableObject, Alertable {
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
    
    let welcomeMessage = "" // FIXME: !!!
    
    func findPatient() {
        guard !patientEmail.isEmpty else {
            presentAlert(AddContractAlerts.emailIsEmpty, .warning)
            return
        }
        guard patientEmail.isEmail() else {
            presentAlert(AddContractAlerts.invalidEmailAlert, .warning)
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
                    self?.presentAlert(AddContractAlerts.contractExistsAlert, .warning)
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
            presentAlert(AddContractAlerts.nameIsEmpty, .warning)
            return
        }
        guard contractEndDate > Date() else {
            presentAlert(AddContractAlerts.contractDateAreOlderThanNow, .warning)
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
                    completion()
                } else {
                    self?.presentGlobalAlert()
                }
            }
        }
    }
}
