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
    internal static func get(for context: NSManagedObjectContext) throws -> User {
        let fetchRequest = User.fetchRequest()
        let objects = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "User all")
        guard let user = objects?.first else {
            throw PersistenceController.ObjectNotFoundError()
        }
        return user
    }
    
    /// Get user from any task
    /// - Returns: optional user instance
    @MainActor public static func get() async throws -> User {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return try await context.crossVersionPerform {
            try get(for: context)
        }
    }
    
    public static func delete() async throws {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        try await context.crossVersionPerform {
            let user = try get(for: context)
            context.delete(user)
            PersistenceController.save(for: context, detailsForLogging: "User delete")
        }
    }
    
    /// Save user avatar data object
    /// - Parameter image: avatar data
    public static func saveAvatar(_ image: Data?) async throws {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        try await context.crossVersionPerform {
            let user = try get(for: context)
            user.avatar = image
            PersistenceController.save(for: context, detailsForLogging: "User save avatar")
        }
    }
    
    /// Save lastHealthSync param to user model
    /// - Parameter lastHealthSync: date last HealthKit sync
    public static func updateLastHealthSync(lastHealthSync: Date) async throws {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        try await context.crossVersionPerform {
            let user = try get(for: context)
            user.lastHealthSync = lastHealthSync
            PersistenceController.save(for: context, detailsForLogging: "User save lastHealthSync")
        }
    }
}
