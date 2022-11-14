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

extension Contract {
    static func createSampleContract1(for viewContext: NSManagedObjectContext) -> Contract {
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
        contract.archive = false
        contract.sent = 24
        contract.received = 24
        contract.shortName = "БББ"
        contract.number = "1"
//        if let unread = data.unread {
//            contract.unread = Int64(unread)
//        }
//        contract.isOnline = data.is_online
        contract.role = "FFF"
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
        
        return contract
    }
    
    static func createSampleContract2(for viewContext: NSManagedObjectContext) -> Contract {
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
        contract.role = "FFF"
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
        
        return contract
    }
    
    static func createSampleContracts(for viewContext: NSManagedObjectContext) {
        _ = createSampleContract1(for: viewContext)
        _ = createSampleContract2(for: viewContext)
    }
}
