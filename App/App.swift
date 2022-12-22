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

@main
struct MedsengerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let persistenceController = PersistenceController.shared
    
    init() {
        UserDefaults.registerDefaultValues()
        if UserDefaults.isHealthKitSyncActive {
            HealthKitSync.shared.authorizeHealthKit { success in
                if success {
                    HealthKitSync.shared.startObservingHKChanges()
                }
            }
        }
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
    
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AppDelegate.self)
    )
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        return true
    }
}
