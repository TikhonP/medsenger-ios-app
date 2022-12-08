//
//  User+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData
import os.log

@objc(User)
public class User: NSManagedObject, CoreDataErasable {
    
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: User.self)
    )
    
    /// Get user form context
    /// - Parameter context: Core Data context
    /// - Returns: optional user instance
    internal static func get(for context: NSManagedObjectContext) -> User? {
        let fetchRequest = User.fetchRequest()
        let objects = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "User all")
        return objects?.first
    }
    
    /// Get user from any task
    /// - Returns: optional user instance
    public static func get() -> User? {
        let context = PersistenceController.shared.container.viewContext
        var user: User?
        context.performAndWait {
            user = get(for: context)
        }
        return user
    }
    
    public static func delete() {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            guard let user = get(for: context) else {
                User.logger.error("Delete User failed: Not found")
                return
            }
            context.delete(user)
            PersistenceController.save(for: context, detailsForLogging: "User delete")
        }
    }
    
    /// Save user avatar data object
    /// - Parameter image: avatar data
    public static func saveAvatar(_ image: Data?) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            guard let user = get(for: context) else { return }
            user.avatar = image
            PersistenceController.save(for: context, detailsForLogging: "User save avatar")
        }
    }
    
    /// Save lastHealthSync param to user model
    /// - Parameter lastHealthSync: date last HealthKit sync
    public static func updateLastHealthSync(lastHealthSync: Date) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let user = get(for: context)
            user?.lastHealthSync = lastHealthSync
            PersistenceController.save(for: context, detailsForLogging: "User save lastHealthSync")
        }
    }
}
