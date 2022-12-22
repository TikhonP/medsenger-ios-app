//
//  SettingsMainFormViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

final class SettingsMainFormViewModel: ObservableObject, Alertable {
    @Published var isEmailNotificationOn: Bool = User.get()?.emailNotifications ?? false
    @Published var showEmailNotificationUpdateRequestLoading = false
    @Published var showPushNotificationUpdateRequestLoading = false
    @Published var alert: AlertInfo?
    
    func updateEmailNotifications(_ value: Bool) {
        guard User.get()?.emailNotifications != value else {
            return
        }
        showEmailNotificationUpdateRequestLoading = true
        Account.shared.updateEmailNotiofication(isEmailNotificationsOn: value) { [weak self] succeeded in
            DispatchQueue.main.async {
                self?.showEmailNotificationUpdateRequestLoading = false
                if succeeded {
                    Account.shared.updateProfile { _ in }
                } else {
                    self?.presentGlobalAlert()
                    self?.showEmailNotificationUpdateRequestLoading = !value
                }
            }
        }
    }
    
    func updatePushNotifications(_ value: Bool) {
        showPushNotificationUpdateRequestLoading = true
        PushNotifications.toggleNotifications(isOn: value) { [weak self] result in
            DispatchQueue.main.async {
                self?.showPushNotificationUpdateRequestLoading = false
                if result == .requestFailed {
                    self?.presentGlobalAlert()
                } else if result == .noFcmToken {
                    self?.presentAlert(title: Text("SettingsMainFormViewModel.noFcmTokenAlertTitle"))
                } else if result == .notGranted {
                    self?.presentAlert(Alert(
                        title: Text("SettingsMainFormViewModel.notificationPermissionNeededAlertTitle"),
                        message: Text("SettingsMainFormViewModel.notificationPermissionNeededAlertMessage"),
                        primaryButton: .cancel(Text("SettingsMainFormViewModel.allowMicrophoneAccessAlertCancelButton", comment: "Not Now")),
                        secondaryButton: .default(Text("SettingsMainFormViewModel.allowMicrophoneAccessAlertSettingsButton", comment: "Settings")) {
                            DispatchQueue.main.async {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        })
                    )
                }
            }
        }
    }
}
