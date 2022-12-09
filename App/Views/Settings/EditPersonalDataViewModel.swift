//
//  EditPersonalDataViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate class EditPersonalDataAlerts {
    static let invalidEmailAlert = AlertInfo(
        title: LocalizedStringKey("Invalid email!").stringValue(), message: "")
    static let nameIsEmpty = AlertInfo(
        title: LocalizedStringKey("Name cannot be empty!").stringValue(),
        message: LocalizedStringKey("Please provide a name to continue.").stringValue())
    static let phoneExists = AlertInfo(
        title: LocalizedStringKey("This phone already in use!").stringValue(),
        message: LocalizedStringKey("Please check if the phone is correct.").stringValue())
}

final class EditPersonalDataViewModel: ObservableObject, Alertable {
    @Published var alert: AlertInfo?
    @Published var showLoading = false
    
    func saveProfileData(name: String, email: String, phone: String, birthday: Date, completion: @escaping () -> Void) {
        guard email.isEmail() else {
            presentAlert(EditPersonalDataAlerts.invalidEmailAlert, .warning)
            return
        }
        guard !name.isEmpty else {
            presentAlert(EditPersonalDataAlerts.nameIsEmpty, .warning)
            return
        }
        showLoading = true
        Account.shared.saveProfileData(name: name, email: email, phone: phone, birthday: birthday) { [weak self] result in
            DispatchQueue.main.async {
                self?.showLoading = false
                switch result {
                case .succeess:
                    completion()
                case .failure:
                    self?.presentGlobalAlert()
                case .phoneExists:
                    self?.presentAlert(EditPersonalDataAlerts.phoneExists, .warning)
                }
            }
        }
    }
}
