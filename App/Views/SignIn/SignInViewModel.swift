//
//  SignInViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate class SignInAlerts {
    static let fillTheFields = AlertInfo(
        title: LocalizedStringKey("Provide auth data!").stringValue(),
        message: LocalizedStringKey("Please fill both username and password fields.").stringValue())
    static let userIsNotActivated = AlertInfo(
        title: LocalizedStringKey("User is not activated!").stringValue(),
        message: "")
    static let userIsNotFound = AlertInfo(
        title: LocalizedStringKey("User is not found!").stringValue(),
        message: "")
    static let invalidPassword = AlertInfo(
        title: LocalizedStringKey("Invalid password!").stringValue(),
        message: "")
}

final class SignInViewModel: ObservableObject, Alertable {
    @Published var login: String = ""
    @Published var password: String = ""
    
    @Published var showLoader = false
    
    @Published var alert: AlertInfo?
    
    func auth() {
        guard !login.isEmpty, !password.isEmpty else {
            alert = SignInAlerts.fillTheFields
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
                    self.presentAlert(SignInAlerts.userIsNotActivated, .error)
                case .incorrectData:
                    self.presentAlert(SignInAlerts.userIsNotFound, .error)
                case .incorrectPassword:
                    self.presentAlert(SignInAlerts.invalidPassword, .error)
                }
            }
        }
    }
}
