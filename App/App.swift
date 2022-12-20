//
//  App.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import os.log
import SwiftUI
import Firebase
import UserNotifications

@main
struct MedsengerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let persistenceController = PersistenceController.shared
    
    init() {
        UserDefaults.registerDefaultValues()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AppDelegate.self)
    )
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Setup firebase notifications
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                AppDelegate.logger.error("Error requesting push notifications authorization: \(error.localizedDescription)")
            }
            if !granted {
                AppDelegate.logger.notice("Failed authorize push notifications")
            }
        }
        
        application.registerForRemoteNotifications()
        
        if UserDefaults.isHealthKitSyncActive {
            HealthKitSync.shared.authorizeHealthKit { success in
                if success {
                    HealthKitSync.shared.startObservingHKChanges()
                }
            }
        }
        
        return true
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
        
        completionHandler([[.banner, .badge, .sound]])
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

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // set to `false` if you don't want to detect tap during other gestures
    }
}
