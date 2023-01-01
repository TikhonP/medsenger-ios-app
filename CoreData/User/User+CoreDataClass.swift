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
    /// - Parameter moc: Core Data context
    /// - Returns: optional user instance
    internal static func get(for moc: NSManagedObjectContext) throws -> User {
        let fetchRequest = User.fetchRequest()
        let objects = try moc.wrappedFetch(fetchRequest, detailsForLogging: "User all")
        guard let user = objects.first else {
            throw PersistenceController.ObjectNotFoundError()
        }
        return user
    }
    
    /// Get user from any task
    /// - Returns: optional user instance
    @MainActor public static func get() async throws -> User {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        return try await moc.crossVersionPerform {
            try get(for: moc)
        }
    }
    
    public static func delete() async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let user = try get(for: moc)
            moc.delete(user)
            try moc.wrappedSave(detailsForLogging: "User delete")
        }
    }
    
    /// Save user avatar data object
    /// - Parameter image: avatar data
    public static func saveAvatar(_ image: Data?) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let user = try get(for: moc)
            user.avatar = image
            try moc.wrappedSave(detailsForLogging: "User save avatar")
        }
    }
    
    /// Save lastHealthSync param to user model
    /// - Parameter lastHealthSync: date last HealthKit sync
    public static func updateLastHealthSync(lastHealthSync: Date) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            let user = try get(for: moc)
            user.lastHealthSync = lastHealthSync
            try moc.wrappedSave(detailsForLogging: "User save lastHealthSync")
        }
    }
}
