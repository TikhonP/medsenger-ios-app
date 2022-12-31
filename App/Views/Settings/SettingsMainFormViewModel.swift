//
//  SettingsMainFormViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class SettingsMainFormViewModel: ObservableObject, Alertable {
    @Published var isEmailNotificationOn: Bool
    @Published var showEmailNotificationUpdateRequestLoading = false
    @Published var showPushNotificationUpdateRequestLoading = false
    @Published var showChangeRoleLoading = false
    @Published var alert: AlertInfo?
    
    init(isEmailNotificationOn: Bool) {
        self.isEmailNotificationOn = isEmailNotificationOn
    }
    
    func updateEmailNotifications(_ value: Bool) async {
        guard let user = try? await User.get(), user.emailNotifications != value else {
            return
        }
        showEmailNotificationUpdateRequestLoading = true
        do {
            try await Account.updateEmailNotiofication(isEmailNotificationsOn: value)
            showEmailNotificationUpdateRequestLoading = false
        } catch {
            showEmailNotificationUpdateRequestLoading = false
            presentGlobalAlert()
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
    
    func changeRole(_ role: UserRole) async {
        showChangeRoleLoading = true
        await Login.changeRole(role)
        showChangeRoleLoading = false
    }
}
