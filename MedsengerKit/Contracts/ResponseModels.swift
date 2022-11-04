//
//  ResponseModels.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct DoctorContract: Decodable {
    let name: String
    let patient_name: String
    let doctor_name: String
    let specialty: String
    let clinic: ClinicDoctorContract
    let mainDoctor: String
    let startDate: String
    let endDate: String
    let contract: Int
    let photo_id: Int?
    let archive: Bool
    let sent: Int
    let received: Int
    let short_name: String
    let state: ContractState
    let number: String
    let unread: Int?
    let is_online: Bool
    let agent_actions: Array<AgentActionResponse>
    let bot_actions: Array<BotActionResponse>
    let agent_tasks: Array<AgentTaskResponse>
    let agents: Array<AgentResponse>
    let role: String
    let patient_helpers: Array<PatientHelperResponse>
    let doctor_helpers: Array<DoctorHelperResponse>
    let compliance: Array<Int>
    let params: Array<ParamResponse>
    let activated: Bool
    let info_materials: Array<InfoMaterialResponse>?
    let can_apply: Bool
    let info_url: String?
//    let public_attachments:
    let scenario: ScenarioResponse?
}

struct ClinicDoctorContract: Decodable {
    let id: Int
    let name: String
    let timezone: String
    let logo_id: Int?
    let full_logo_id: Int?
    let nonsquare_logo_id: Int?
    let video_enabled: Bool
    let phone_paid: Bool
    let phone: String
}

enum ContractState: String, Decodable {
    case noMessages = "no_messages" // FIXME: !!!
    case unread = "unread"
}

struct AgentActionResponse: Decodable {
    let link: URL
    let name: String
    let type: String
    let api_link: URL
    let is_setup: Bool
}

struct BotActionResponse: Decodable {
    let link: URL
    let name: String
    let type: String
    let api_link: URL
    let is_setup: Bool
}

struct AgentTaskResponse: Decodable {
    let action_link: URL
    let api_action_link: URL
    let agent_name: String
    let number: Int
    let target_number: Int
    let is_important: Bool
    let is_done: Bool
    let date: Date
    let done: Date?
    let text: String
    let available: Int
}

struct AgentResponse: Decodable {
    let id: Int
    let name: String
    let description: String
    let open_settings_in_blank: Bool
}

struct PatientHelperResponse: Decodable {
    let id: Int
    let name: String
    let role: String
}

struct DoctorHelperResponse: Decodable {
    let id: Int
    let name: String
    let role: String
}

struct ParamResponse: Decodable {
    let id: Int
    let name: String
    let value: String
    let created_at: Date
    let updated_at: Date
}

struct InfoMaterialResponse: Decodable {
    let name: String
    let link: URL
}

struct ScenarioResponse: Decodable {
    let name: String
    let description: String
    let preset: String
}

extension DoctorContract {
    var startDateAsDate: Date? {
        let formatter = DateFormatter.ddMMyyyy
        return formatter.date(from: startDate)
    }
    
    var endDateAsDate: Date? {
        let formatter = DateFormatter.ddMMyyyyAndTime
        return formatter.date(from: endDate)
    }
}
