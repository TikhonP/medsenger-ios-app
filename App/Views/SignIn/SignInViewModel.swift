//
//  SignInViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

struct SignInAlertInfo: AlertInfo {
    enum AlertType {
        case fillTheFields
        case userIsNotActivated
        case userIsNotFound
        case invalidPassword
        case global
    }
    
    let id: AlertType
    let title: String
    let message: String
}

class SignInAlerts {
    static let fillTheFields = SignInAlertInfo(
        id: .fillTheFields,
        title: LocalizedStringKey("Provide auth data!").stringValue(),
        message: LocalizedStringKey("Please fill both username and password fields.").stringValue())
    static let userIsNotActivated = SignInAlertInfo(
        id: .userIsNotActivated,
        title: LocalizedStringKey("User is not activated!").stringValue(),
        message: "")
    static let userIsNotFound = SignInAlertInfo(
        id: .userIsNotFound,
        title: LocalizedStringKey("User is not found!").stringValue(),
        message: "")
    static let invalidPassword = SignInAlertInfo(
        id: .invalidPassword,
        title: LocalizedStringKey("Invalid password!").stringValue(),
        message: "")
}

final class SignInViewModel: ObservableObject {
    @Published var login: String = ""
    @Published var password: String = ""
    
    @Published var showLoader = false
    
    @Published var alert: SignInAlertInfo?
    
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
                    let globalAlert = ContentViewModel.shared.getGlobalAlert()
                    if !globalAlert.title.isEmpty {
                        self.alert = SignInAlertInfo(id: .global, title: globalAlert.title, message: globalAlert.message)
                    }
                case .userIsNotActivated:
                    self.alert = SignInAlerts.userIsNotActivated
                case .incorrectData:
                    self.alert = SignInAlerts.userIsNotFound
                case .incorrectPassword:
                    self.alert = SignInAlerts.invalidPassword
                }
            }
        }
    }
}
