//
//  User.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension User {
    private static func get(context: NSManagedObjectContext) -> User {
        let objects: [User]? = {
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            return try? context.fetch(fetchRequest)
        }()
        guard let user = objects?.first else {
            return User(context: context)
        }
        return user
    }
    
    class func save(isDoctor: Bool, isPatient: Bool, name: String, email: String?, birthday: Date, phone: String?, shortName: String, hasPhoto: Bool, emailNotifications: Bool, avatar: Data? = nil) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let user = get(context: context)
            
            user.isDoctor = isDoctor
            user.isPatient = isPatient
            user.name = name
            user.email = email
            user.birthday = birthday
            user.phone = phone
            user.shortName = shortName
            user.hasPhoto = hasPhoto
            user.emailNotifications = emailNotifications
            
            if let avatar = avatar {
                user.avatar = avatar
            }
            
            if user.role == nil {
                if isDoctor && !isPatient {
                    user.role = UserRole.patient.rawValue
                } else if isPatient && !isDoctor {
                    user.role = UserRole.doctor.rawValue
                }
            }
            
            PersistenceController.save(context: context)
        }
    }
    
    class func saveAvatar(data: Data?) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let user = get(context: context)
            user.avatar = data
            PersistenceController.save(context: context)
        }
    }
    
    class func delete() {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let context = PersistenceController.shared.container.viewContext
            let user = get(context: context)
            context.delete(user)
        }
    }
    
    class func setRole(role: UserRole) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let user = get(context: context)
            
            user.role = role.rawValue
            
            PersistenceController.save(context: context)
        }
    }
    
    class func getRole() -> UserRole? {
        let context = PersistenceController.shared.container.viewContext
        var userRole: UserRole? = nil
        context.performAndWait {
            let user = get(context: context)
            guard let role = user.role else {
                return
            }
            userRole = UserRole(rawValue: role)
            return
        }
        return userRole
    }
}
