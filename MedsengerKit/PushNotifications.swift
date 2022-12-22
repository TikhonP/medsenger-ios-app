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
    
    static func onChatsViewAppear() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if (((settings.authorizationStatus == .authorized) ||
                (settings.authorizationStatus == .provisional) ||
                 (settings.authorizationStatus == .ephemeral)) &&
                  !UserDefaults.isPushNotificationsOn) ||
                   settings.authorizationStatus == .notDetermined {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        PushNotifications.logger.error("Error requesting push notifications authorization: \(error.localizedDescription)")
                    }
                    if granted {
                        guard let fcmToken = UserDefaults.fcmToken else {
                            PushNotifications.logger.error("No fcm token")
                            UserDefaults.isPushNotificationsOn = false
                            return
                        }
                        Account.shared.updatePushNotifications(fcmToken: fcmToken, action: .storeToken) { succeeded in
                            if succeeded {
                                UserDefaults.isPushNotificationsOn = true
                            } else {
                                UserDefaults.isPushNotificationsOn = false
                            }
                        }
                    } else {
                        UserDefaults.isPushNotificationsOn = false
                        PushNotifications.logger.notice("Failed authorize push notifications")
                    }
                }
            }
        }
    }
    
    enum ToggleNotificationsResult {
        case success, notGranted, requestFailed, noFcmToken
    }
    
    static func toggleNotifications(isOn: Bool, completion: @escaping (_ result: ToggleNotificationsResult) -> Void) {
        if isOn {
            guard let fcmToken = UserDefaults.fcmToken else {
                UserDefaults.isPushNotificationsOn = false
                completion(.noFcmToken)
                return
            }
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                guard (settings.authorizationStatus == .authorized) ||
                        (settings.authorizationStatus == .provisional) else {
                    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if let error = error {
                            PushNotifications.logger.error("Error requesting push notifications authorization: \(error.localizedDescription)")
                        }
                        if granted {
                            Account.shared.updatePushNotifications(fcmToken: fcmToken, action: .storeToken) { succeeded in
                                if succeeded {
                                    UserDefaults.isPushNotificationsOn = true
                                    completion(.success)
                                } else {
                                    UserDefaults.isPushNotificationsOn = false
                                    completion(.requestFailed)
                                }
                            }
                        } else {
                            UserDefaults.isPushNotificationsOn = false
                            PushNotifications.logger.notice("Failed authorize push notifications")
                            completion(.notGranted)
                        }
                    }
                    return
                }
                Account.shared.updatePushNotifications(fcmToken: fcmToken, action: .storeToken) { succeeded in
                    if succeeded {
                        UserDefaults.isPushNotificationsOn = true
                        completion(.success)
                    } else {
                        UserDefaults.isPushNotificationsOn = false
                        completion(.requestFailed)
                    }
                }
            }
        } else {
            guard let fcmToken = UserDefaults.fcmToken else {
                UserDefaults.isPushNotificationsOn = false
                completion(.success)
                return
            }
            Account.shared.updatePushNotifications(fcmToken: fcmToken, action: .removeToken) { succeeded in
                if succeeded {
                    UserDefaults.isPushNotificationsOn = false
                    completion(.success)
                } else {
                    UserDefaults.isPushNotificationsOn = true
                    completion(.requestFailed)
                }
            }
        }
    }
    
    static func changeRoleFcmToken() {
        guard let fcmToken = UserDefaults.fcmToken, UserDefaults.isPushNotificationsOn else {
            return
        }
        Account.shared.updatePushNotifications(fcmToken: fcmToken, action: .removeToken) { _ in
            guard let fcmToken = UserDefaults.fcmToken else {
                return
            }
            Account.shared.updatePushNotifications(fcmToken: fcmToken, action: .storeToken) { succeeded in
                UserDefaults.isPushNotificationsOn = succeeded
            }
        }
    }
    
    static func signOutFcmToken() {
        guard let fcmToken = UserDefaults.fcmToken, UserDefaults.isPushNotificationsOn else {
            return
        }
        Account.shared.updatePushNotifications(fcmToken: fcmToken, action: .removeToken) { _ in }
        UserDefaults.isPushNotificationsOn = false
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
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
