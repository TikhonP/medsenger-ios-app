//
//  ResponseModels.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

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
