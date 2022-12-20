//
//  UserPreview.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct UserPreview {
    static let context = PersistenceController.preview.container.viewContext
    
    static let userForChatsViewPreview = createSampleUser(for: context)
    
    static func createSampleUser(for viewContext: NSManagedObjectContext) -> User {
        let user = User(context: viewContext)
        
        user.name = "Караулькин Игорь Васильевич"
        user.email = "aboba57@mail.ru"
        user.phone = "+74203216969"
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
