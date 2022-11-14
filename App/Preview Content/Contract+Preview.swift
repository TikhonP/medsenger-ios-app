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

let sampleContract1 = Contract.JsonDecoderDoctor(
    name: "Василий Ларионович Б",
    patient_name: "Анатолий Маркович Я",
    doctor_name: "Василий Ларионович Б",
    specialty: "Практолог",
    clinic: Clinic.JsonDecoderFromContract(
        id: 23,
        name: "Клиника практологии доктора изюмского",
        timezone: "Europe/Moscow",
        logo_id: nil,
        full_logo_id: nil,
        nonsquare_logo_id: nil,
        video_enabled: false,
        phone_paid: false,
        phone: "+1232306969"),
    mainDoctor: "Василий Ларионович Б",
    startDate: "11.06.2020",
    endDate: "31.09.2024 (4:20)",
    contract: 1324,
    photo_id: nil,
    archive: false,
    sent: 24, received: 24,
    short_name: "БББ",
    state: .noMessages,
    number: "1",
    unread: nil,
    is_online: false,
    agent_actions: [],
    bot_actions: [],
    agent_tasks: [],
    agents: [],
    role: "FFF",
    patient_helpers: [],
    doctor_helpers: [],
    compliance: [11, 22],
    params: [],
    activated: true,
    info_materials: nil,
    can_apply: true,
    info_url: nil,
    scenario: nil
)

extension Contract {
    static func createSampleContracts(for viewContext: NSManagedObjectContext) {
        Contract.saveContractsFromJson(data: [sampleContract1], archive: false)
        
        if let img = UIImage(named: "UserAvatarExample") {
            guard let data = img.jpegData(compressionQuality: 1) else { return }
            Contract.saveAvatar(id: sampleContract1.contract, image: data)
        }
    }
}
