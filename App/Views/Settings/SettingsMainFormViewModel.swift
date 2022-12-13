//
//  SettingsMainFormViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

fileprivate class MainFormAlerts {
    
}

final class SettingsMainFormViewModel: ObservableObject, Alertable {
    @Published var isEmailNotificationOn: Bool = User.get()?.emailNotifications ?? false
    @Published var showEmailNotificationUpdateRequestLoading = false
    
    @Published var isPushNotificationOn: Bool = UserDefaults.isPushNotificationsOn
    @Published var showPushNotificationUpdateRequestLoading = false
    
    @Published var alert: AlertInfo?
    
    func updateEmailNotifications(_ value: Bool) {
        guard User.get()?.emailNotifications != value else {
            return
        }
        showEmailNotificationUpdateRequestLoading = true
        Account.shared.updateEmailNotiofication(emailNotify: value) { [weak self] succeeded in
            DispatchQueue.main.async {
                self?.showEmailNotificationUpdateRequestLoading = false
                if succeeded {
                    Account.shared.updateProfile()
                } else {
                    self?.presentGlobalAlert()
                    self?.showEmailNotificationUpdateRequestLoading = !value
                }
            }
        }
    }
    
    func updatePushNotifications(_ value: Bool) {
        if let fcmToken = UserDefaults.fcmToken {
            showPushNotificationUpdateRequestLoading = true
            Account.shared.updatePushNotifications(fcmToken: fcmToken, storeOrRemove: value) { [weak self] succeeded in
                DispatchQueue.main.async {
                    self?.showPushNotificationUpdateRequestLoading = false
                    if !succeeded {
                        self?.presentGlobalAlert()
                        UserDefaults.isPushNotificationsOn = false
                    }
                }
            }
        } else {
            isPushNotificationOn = false
            UserDefaults.isPushNotificationsOn = false
        }
    }
}
