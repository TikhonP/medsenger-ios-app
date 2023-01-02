//
//  PushNotifications.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import UIKit
import os.log
import Firebase
import Foundation
import UserNotifications

final class PushNotifications {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PushNotifications.self)
    )
    
    static func onChatsViewAppear() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        if (((settings.authorizationStatus == .authorized) ||
             (settings.authorizationStatus == .provisional) ||
             (settings.authorizationStatus == .ephemeral)) &&
            !UserDefaults.isPushNotificationsOn) ||
            settings.authorizationStatus == .notDetermined {
            
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    guard let fcmToken = UserDefaults.fcmToken else {
                        PushNotifications.logger.error("No fcm token")
                        UserDefaults.isPushNotificationsOn = false
                        return
                    }
                    do {
                        try await Account.updatePushNotifications(fcmToken: fcmToken, action: .storeToken)
                        UserDefaults.isPushNotificationsOn = true
                    } catch {
                        UserDefaults.isPushNotificationsOn = false
                    }
                } else {
                    UserDefaults.isPushNotificationsOn = false
                    PushNotifications.logger.notice("Failed authorize push notifications")
                }
            } catch {
                PushNotifications.logger.error("Error requesting push notifications authorization: \(error.localizedDescription)")
            }
        }
    }
    
    enum ToggleNotificationsError: Error {
        case notGranted, noFcmToken
    }
    
    static func toggleNotifications(isOn: Bool) async throws {
        if isOn {
            guard let fcmToken = UserDefaults.fcmToken else {
                UserDefaults.isPushNotificationsOn = false
                throw ToggleNotificationsError.noFcmToken
            }
            
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            guard (settings.authorizationStatus == .authorized) ||
                    (settings.authorizationStatus == .provisional) else {
                
                do {
                    let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                    if granted {
                        do {
                            try await Account.updatePushNotifications(fcmToken: fcmToken, action: .storeToken)
                            UserDefaults.isPushNotificationsOn = true
                        } catch {
                            UserDefaults.isPushNotificationsOn = false
                            throw error
                        }
                    } else {
                        UserDefaults.isPushNotificationsOn = false
                        PushNotifications.logger.notice("Failed authorize push notifications")
                        throw ToggleNotificationsError.notGranted
                    }
                } catch {
                    PushNotifications.logger.error("Error requesting push notifications authorization: \(error.localizedDescription)")
                    throw error
                }
                
                return
            }
            do {
                try await Account.updatePushNotifications(fcmToken: fcmToken, action: .storeToken)
                UserDefaults.isPushNotificationsOn = true
            } catch {
                UserDefaults.isPushNotificationsOn = false
                throw error
            }
        } else {
            guard let fcmToken = UserDefaults.fcmToken else {
                UserDefaults.isPushNotificationsOn = false
                return
            }
            do {
                try await Account.updatePushNotifications(fcmToken: fcmToken, action: .removeToken)
                UserDefaults.isPushNotificationsOn = false
            } catch {
                UserDefaults.isPushNotificationsOn = true
                throw error
            }
        }
    }
    
    static func removeOldFcmToken() async {
        guard let fcmToken = UserDefaults.fcmToken, UserDefaults.isPushNotificationsOn else {
            return
        }
        do {
            try await Account.updatePushNotifications(fcmToken: fcmToken, action: .removeToken)
            UserDefaults.isPushNotificationsOn = false
        } catch {
            UserDefaults.isPushNotificationsOn = true
        }
    }
    
    static func storeFcmTokenAsNewRole() async {
        guard let fcmToken = UserDefaults.fcmToken else {
            return
        }
        do {
            try await Account.updatePushNotifications(fcmToken: fcmToken, action: .storeToken)
            UserDefaults.isPushNotificationsOn = true
        } catch {
            UserDefaults.isPushNotificationsOn = false
        }
    }
    
    static func signOutFcmToken() async {
        guard let fcmToken = UserDefaults.fcmToken, UserDefaults.isPushNotificationsOn else {
            return
        }
        try? await Account.updatePushNotifications(fcmToken: fcmToken, action: .removeToken)
        UserDefaults.isPushNotificationsOn = false
    }
}

extension AppDelegate: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        UserDefaults.fcmToken = fcmToken
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let contracId = userInfo["contract_id"] as? String, let contracId = Int(contracId) {
            if contracId == ContentViewModel.shared.openedChatContractId {
                completionHandler([])
                return
            }
        }
        
        completionHandler([.banner, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AppDelegate.logger.error("Failed register push notifications: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let contracId = userInfo["contract_id"] as? String, let contracId = Int(contracId) {
            ContentViewModel.shared.openChat(with: contracId)
        }
        completionHandler()
    }
}
