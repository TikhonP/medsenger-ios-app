//
//  Contract+Preview.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct ContractPreviews {
    static let context = PersistenceController.preview.container.viewContext
    
    // https://youtu.be/ZyFDqMpGqxw
    static let contractForPatientChatRowPreview = ContractPreviews.createSampleContract(
        name: "Доктор Изюмский",
        patientName: "Омар Васильевич",
        doctorName: "Доктор Изюмский",
        specialty: "Проктолог 🌶️",
        mainDoctor: "Доктор Изюмский",
        archive: false,
        shortName: "Изюмский",
        number: "69",
        unread: Int.random(in: 0...5),
        isOnline: false,
        role: "Пройдет там, где другие обосрутся",
        activated: true,
        scenarioName: "Мурманская гильдия практологов",
        scenarioDescription: nil,
        scenarioPreset: nil,
        lastFetchedMessage: nil,
        clinic: ClinicPreviews.createSampleClinic(
            name: "Клиника практологии доктора Изюмского",
            videoEnabled: false,
            logo: getImageData(named: "ДокторИзюмскийКлиника"),
            for: context),
        avatar: getImageData(named: "ПрактологИзюмский"),
        doctorAvatar: nil,
        patientAvatar: nil,
        isConsilium: false,
        for: context)
    
    // Доктор! А это вам!
    static let contractForConsiliumChatRowPreview = ContractPreviews.createSampleContract(
        name: "Доктор Роза",
        patientName: "Омар Васильевич",
        doctorName: "Доктор Роза",
        specialty: "Цветочник",
        mainDoctor: "Доктор Роза",
        archive: false,
        shortName: "Роза",
        number: "420",
        unread: Int.random(in: 0...5),
        isOnline: false,
        role: "Наскипидаренный",
        activated: true,
        scenarioName: "Криволинейная терапия",
        scenarioDescription: nil,
        scenarioPreset: nil,
        lastFetchedMessage: nil,
        clinic: ClinicPreviews.createSampleClinic(
            name: "Нижнеусрийское отделение херопрактики",
            videoEnabled: false,
            logo: getImageData(named: "НижнеусрийскоеОтделениеХеропрактики"),
            for: context),
        avatar: nil,
        doctorAvatar: getImageData(named: "ДокторРоза"),
        patientAvatar: getImageData(named: "ОмарВасильевич"),
        isConsilium: true,
        for: context)
    
    static func getImageData(named: String) -> Data? {
        UIImage(named: named)?.jpegData(compressionQuality: 1)
    }
    
    static func createSampleContract(
        name: String,
        patientName: String,
        doctorName: String,
        specialty: String,
        mainDoctor: String,
        archive: Bool,
        shortName: String,
        number: String,
        unread: Int,
        isOnline: Bool,
        role: String,
        activated: Bool,
        scenarioName: String?,
        scenarioDescription: String?,
        scenarioPreset: String?,
        lastFetchedMessage: Message?,
        clinic: Clinic?,
        avatar: Data?,
        doctorAvatar: Data?,
        patientAvatar: Data?,
        isConsilium: Bool,
        for viewContext: NSManagedObjectContext
    ) -> Contract {
        let contract = Contract(context: viewContext)
        
        contract.id = Int64.random(in: 0...1000)
        contract.name = name
        contract.patientName = patientName
        contract.doctorName = doctorName
        contract.specialty = specialty
        contract.mainDoctor = mainDoctor
        contract.startDate = Date()
        contract.endDate = Date()
        // Skip photo ID
        contract.archive = archive
        contract.sent = Int64.random(in: 0...50)
        contract.received = Int64.random(in: 0...50)
        contract.shortName = shortName
        contract.number = number
        contract.unread = Int64(unread)
        contract.isOnline = isOnline
        contract.role = role
        contract.activated = activated
        contract.canApplySubmissionToContractExtension = true
        // Skip info url
        contract.scenarioName = scenarioName
        contract.scenarioDescription = scenarioDescription
        contract.scenarioPreset = scenarioPreset
        // Skip sortRating
        contract.lastFetchedMessage = lastFetchedMessage
        contract.clinic = clinic
        contract.avatar = avatar
        contract.doctorAvatar = doctorAvatar
        contract.patientAvatar = patientAvatar
        contract.isConsilium = isConsilium
        
        return contract
    }
}

extension Contract {
    static func createSampleContract2Archive(for viewContext: NSManagedObjectContext) -> Contract {
        let contract = Contract(context: viewContext)
        
        contract.id = 24
        contract.name = "Василий Ларионович Б"
        contract.patientName = "Анатолий Маркович Я"
        contract.doctorName = "Василий Ларионович Б"
        contract.specialty = "Практолог"
        contract.mainDoctor = "Василий Ларионович Б"
        contract.startDate = Date()
        contract.endDate = Date()
        //        if let photo_id = data.photo_id {
        //            contract.photoId = Int64(photo_id)
        //        }
        contract.archive = true
        contract.sent = 24
        contract.received = 24
        contract.shortName = "БББ"
        contract.number = "1"
        //        if let unread = data.unread {
        //            contract.unread = Int64(unread)
        //        }
        //        contract.isOnline = data.is_online
        contract.role = "Врач практолог"
        contract.activated = true
        contract.canApplySubmissionToContractExtension = true
        //        if let urlString = data.info_url, let url = URL(string: urlString) {
        //            contract.infoUrl = url
        //        }
        //        contract.scenarioName = data.scenario?.name
        //        contract.scenarioDescription = data.scenario?.description
        //        contract.scenarioPreset = data.scenario?.preset
        contract.sortRating = 0
        
        if let img = UIImage(named: "UserAvatarExample") {
            guard let data = img.jpegData(compressionQuality: 1) else { return contract }
            contract.avatar = data
        }
        
        contract.lastFetchedMessage = Message.getSampleMessage(for: viewContext)
//        contract.clinic = Clinic.createSampleClinic(for: viewContext)
        
        contract.scenarioName = "Персональный сценарий"
        
        return contract
    }
    
    static func createSampleContracts(for viewContext: NSManagedObjectContext) {
        _ = createSampleContract2Archive(for: viewContext)
    }
}
