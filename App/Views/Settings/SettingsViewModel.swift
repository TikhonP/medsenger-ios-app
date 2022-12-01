//
//  SettingsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var isPushNotificationOn: Bool = UserDefaults.isPushNotificationsOn
    @Published var isEmailNotificationOn: Bool = User.get()?.emailNotifications ?? false
    @Published var isHealthKitSyncActive: Bool = UserDefaults.isHealthKitSyncActive
    
    @Published var showEditProfileData: Bool = false
    
    @Published var showSelectAvatarOptions: Bool = false
    @Published var showSelectPhotosSheet = false
    @Published var showTakeImageSheet = false
    @Published var selectedAvatarImage = Data()
    
    func getAvatar() {
        Account.shared.fetchAvatar()
    }
    
    func signOut() {
        Login.shared.signOut()
    }
    
    func updateProfile() {
        Account.shared.updateProfile()
    }
    
    func uploadAvatar(image: Data) {
        Account.shared.uploadAvatar(image)
    }
    
    func saveProfileData(name: String, email: String, phone: String, birthday: Date, completion: @escaping () -> Void) {
        Account.shared.saveProfileData(name: name, email: email, phone: phone, birthday: birthday, completion: completion)
    }
    
    func updateEmailNotifications() {
        Account.shared.updateEmailNotiofication(emailNotify: isEmailNotificationOn) {
            Account.shared.updateProfile()
        }
    }
    
    func updatePushNotifications() {
        if let fcmToken = UserDefaults.fcmToken {
            Account.shared.updatePushNotifications(fcmToken: fcmToken, storeOrRemove: isPushNotificationOn)
        }
    }
    
    func toggleEditPersonalData() {
        withAnimation {
            showEditProfileData.toggle()
        }
    }
    
    func updateHealthKitSync() {
        if isHealthKitSyncActive {
            HealthKitSync.shared.authorizeHealthKit { [weak self] success in
                if success {
                    UserDefaults.isHealthKitSyncActive = true
                    HealthKitSync.shared.syncDataFromHealthKit {
                        print("lol kek")
                        HealthKitSync.shared.startObservingHKChanges()
                    }
                } else {
                    self?.isHealthKitSyncActive = false
                    UserDefaults.isHealthKitSyncActive = false
                }
            }
        } else {
            UserDefaults.isHealthKitSyncActive = false
        }
    }
}
