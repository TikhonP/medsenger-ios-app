//
//  User+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    enum Role: String {
        case patient = "patient"
        case doctor = "doctor"
        
    var clientsForNetworkRequest: String {
            switch self {
            case .patient:
                return "doctors"
            case .doctor:
                return "patients"
            }
        }
    }
    
    var role: Role? {
        get {
            guard let roleString = roleString else {
                return nil
            }
            return Role(rawValue: roleString)
        }
        set {
            guard let newValue = newValue else { return }
            roleString = newValue.rawValue
        }
    }
    
    class var role: Role? {
        get {
            guard let user = User.get(), let roleString = user.roleString else {
                return nil
            }
            return Role(rawValue: roleString)
        }
        set {
            PersistenceController.shared.container.performBackgroundTask { (context) in
                guard let user = User.get(context: context), let newValue = newValue else { return }
                user.roleString = newValue.rawValue
                PersistenceController.save(context: context)
            }
        }
    }
    
    /// Get user form context
    /// - Parameter context: Core Data context
    /// - Returns: optional user instance
    private class func get(context: NSManagedObjectContext) -> User? {
        let objects: [User]? = {
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            do {
                return try context.fetch(fetchRequest)
            } catch {
                print("Faild to get `User` from core data: \(error.localizedDescription)")
                return nil
            }
        }()
        guard let user = objects?.first else {
            return nil
        }
        return user
    }
    
    /// Get user from any task
    /// - Returns: optional user instance
    class func get() -> User? {
        let context = PersistenceController.shared.container.viewContext
        var user: User?
        context.performAndWait {
            user = get(context: context)
        }
        return user
    }
    
    class func delete() {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            guard let user = get(context: context) else {
                print("Delete User failed: Not found")
                return
            }
            context.delete(user)
            PersistenceController.save(context: context)
        }
    }
    
    class func saveAvatar(data: Data?) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            guard let user = get(context: context) else { return }
            user.avatar = data
            PersistenceController.save(context: context)
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
    
    class func saveUserFromJson(data: JsonDecoder) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let user = {
                guard let user = get(context: context) else {
                    return User(context: context)
                }
                return user
            }()
            
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
            
            if user.roleString == nil {
                if data.isDoctor && !data.isPatient {
                    user.roleString = Role.patient.rawValue
                } else if data.isPatient && !data.isDoctor {
                    user.roleString = Role.doctor.rawValue
                }
            }
            
            PersistenceController.save(context: context)
            
            for clinicData in data.clinics {
                let _ = Clinic.saveFromJson(data: clinicData, context: context)
            }
        }
    }
}

#if DEBUG
import UIKit

extension User {
    class func createSampleUser(for viewContext: NSManagedObjectContext) -> User {
        let user = User(context: viewContext)
        
        user.name = "Караулькин Игорь Васильевич"
        user.email = "aboba57@mail.ru"
        user.phone = "+74203216969"
        user.role = Role.patient
        user.shortName = "Игорь"
        user.emailNotifications = true
        user.hasApp = true
        user.hasPhoto = true
        user.isDoctor = true
        user.isPatient = true
    
        user.birthday = Calendar(identifier: .gregorian)
            .date(from: DateComponents(year: 1970, month: 1, day: 1))
        
        user.lastHealthSync = Date()

        if let img = UIImage(named: "UserAvatarExample") {
            let data = img.jpegData(compressionQuality: 1)
            user.avatar = data
        }

        return user
    }
}
#endif
