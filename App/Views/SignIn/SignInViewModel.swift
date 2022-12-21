//
//  SignInViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

final class SignInViewModel: ObservableObject, Alertable {
    @Published var login: String = ""
    @Published var password: String = ""
    @Published var showLoader = false
    @Published var alert: AlertInfo?
    
    func auth() {
        guard !login.isEmpty, !password.isEmpty else {
            presentAlert(
                title: Text("SignInViewModel.fieldsAreEmptyAlertTitle", comment: "Provide auth data!"),
                message: Text("SignInViewModel.fieldsAreEmptyAlertMessage", comment: "Please fill both username and password fields."), .warning)
            return
        }
        showLoader = true
        Login.shared.signIn(login: login, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.showLoader = false
                switch result {
                case .success:
                    break
                case .unknownError:
                    self.presentGlobalAlert()
                case .userIsNotActivated:
                    self.presentAlert(title: Text("SignInViewModel.userIsNotActivatedAlertTitle", comment: "User is not activated!"), .error)
                case .incorrectData:
                    self.presentAlert(title: Text("SignInViewModel.userIsNotFoundAlertTitle", comment: "User is not found!"), .error)
                case .incorrectPassword:
                    self.presentAlert(title: Text("SignInViewModel.invalidPasswordALertTitle", comment: "Invalid password!"), .error)
                }
            }
        }
    }
}
