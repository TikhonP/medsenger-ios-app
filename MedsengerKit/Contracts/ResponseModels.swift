//
//  ResponseModels.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

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
