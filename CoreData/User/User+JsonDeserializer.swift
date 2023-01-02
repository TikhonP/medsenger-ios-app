//
//  User+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension User {
    public struct JsonDecoder: Decodable, Sendable {
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
    
    private static func saveFromJson(_ data: JsonDecoder, for moc: NSManagedObjectContext) -> User {
        let user = (try? get(for: moc)) ?? User(context: moc)
        
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
    
    public static func saveUserFromJson(_ data: JsonDecoder) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            _ = saveFromJson(data, for: moc)
            
            for clinicData in data.clinics {
                _ = Clinic.saveFromJson(clinicData, for: moc)
            }
            
            try moc.wrappedSave(detailsForLogging: "User save from JsonDecoder")
        }
    }
}
