//
//  ChangePasswordViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

final class ChangePasswordViewModel: ObservableObject, Alertable {
    @Published var alert: AlertInfo?
    @Published var showLoading = false
    
    func changePasswordRequest(password1: String, password2: String, completion: @escaping () -> Void) {
        guard password1.count > 6 else {
            presentAlert(
                title: "Passwords do not match!",
                message: "Please check that the passwords are the same.", .warning)
            return
        }
        guard password1 == password2 else {
            presentAlert(title: "Password must be more than 6 characters", .warning)
            return
        }
        showLoading = true
        Login.shared.changePassword(newPassword: password1, completion: { [weak self] succeeded in
            DispatchQueue.main.async {
                self?.showLoading = false
                if succeeded {
                    completion()
                } else {
                    self?.presentGlobalAlert()
                }
            }
        })
    }
}
