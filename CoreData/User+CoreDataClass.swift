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
public class User: NSManagedObject {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: User.self)
    )
    
    /// Get user form context
    /// - Parameter context: Core Data context
    /// - Returns: optional user instance
    private class func get(for context: NSManagedObjectContext) -> User? {
        let fetchRequest = User.fetchRequest()
        let objects = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "User all")
        return objects?.first
    }
    
    /// Get user from any task
    /// - Returns: optional user instance
    class func get() -> User? {
        let context = PersistenceController.shared.container.viewContext
        var user: User?
        context.performAndWait {
            user = get(for: context)
        }
        return user
    }
    
    class func delete() {
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
    class func saveAvatar(_ image: Data?) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            guard let user = get(for: context) else { return }
            user.avatar = image
            PersistenceController.save(for: context, detailsForLogging: "User save avatar")
        }
    }
}

extension User {
    struct JsonDecoder: Decodable {
        let api_token: String?
        let isDoctor: Bool
        let isPatient: Bool
        let name: String
        let clinics: Array<Clinic.JsonDecoderFromCheck>
        let email: String?
        let birthday: String
        let phone: String?
        let short_name: String
        let hasPhoto: Bool
        let email_notifications: Bool
        let hasApp: Bool
        let last_health_sync: Date?
        
        var birthdayAsDate: Date {
            let dateFormatter = DateFormatter.ddMMyyyy
            return dateFormatter.date(from: birthday)!
        }
    }
    
    class func saveFromJson(_ data: JsonDecoder, for context: NSManagedObjectContext) -> User {
        let user = get(for: context) ?? User(context: context)
        
        user.isDoctor = data.isDoctor
        user.isPatient = data.isPatient
        user.name = data.name
        user.email = data.email
        user.birthday = data.birthdayAsDate
        user.phone = data.phone
        user.shortName = data.short_name
        user.hasPhoto = data.hasPhoto
        user.emailNotifications = data.email_notifications
        user.hasApp = data.hasApp
        user.lastHealthSync = data.last_health_sync
        
        if UserDefaults.userRole == .unknown {
            if data.isDoctor && !data.isPatient {
                UserDefaults.userRole = .doctor
            } else if data.isPatient && !data.isDoctor {
                UserDefaults.userRole = .patient
            }
        }
        
        return user
    }
    
    static func saveUserFromJson(_ data: JsonDecoder) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            _ = saveFromJson(data, for: context)
            
            for clinicData in data.clinics {
                _ = Clinic.saveFromJson(clinicData, for: context)
            }
            
            PersistenceController.save(for: context, detailsForLogging: "User save from JsonDecoder")
        }
    }
}
