//
//  PersistenceController+User.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension PersistenceController {
    private static func getUser(context: NSManagedObjectContext) -> User {
        let objects: [User]? = {
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            return try? context.fetch(fetchRequest)
        }()
        guard let user = objects?.first else {
            return User(context: context)
        }
        return user
    }
    
    class func saveUser(isDoctor: Bool, isPatient: Bool, name: String, email: String?, birthday: Date, phone: String?, shortName: String, hasPhoto: Bool, emailNotifications: Bool, avatar: Data? = nil) {
        let context = PersistenceController.shared.container.viewContext
        let user = getUser(context: context)
        
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
    
    class func saveUserAvatar(data: Data?) {
        let context = PersistenceController.shared.container.viewContext
        let user = getUser(context: context)
        
        user.avatar = data
        
        PersistenceController.save(context: context)
    }
    
    class func deleteUser() {
        let context = PersistenceController.shared.container.viewContext
        let user = getUser(context: context)
        context.delete(user)
    }
    
    class func setUserRole(role: UserRole) {
        let context = PersistenceController.shared.container.viewContext
        let user = getUser(context: context)
        
        user.role = role.rawValue
        
        PersistenceController.save(context: context)
    }
}
