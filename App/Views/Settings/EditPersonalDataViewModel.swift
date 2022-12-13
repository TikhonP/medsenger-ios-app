//
//  EditPersonalDataViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

final class EditPersonalDataViewModel: ObservableObject, Alertable {
    @Published var alert: AlertInfo?
    @Published var showLoading = false
    
    func saveProfileData(name: String, email: String, phone: String, birthday: Date, completion: @escaping () -> Void) {
        guard email.isEmail() else {
            presentAlert(title: "Invalid email!", .warning)
            return
        }
        guard !name.isEmpty else {
            presentAlert(
                title: "Name cannot be empty!",
                message: "Please provide a name to continue.", .warning)
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
                    self?.presentAlert(
                        title: "This phone already in use!",
                        message: "Please check if the phone is correct.", .warning)
                }
            }
        }
    }
}
