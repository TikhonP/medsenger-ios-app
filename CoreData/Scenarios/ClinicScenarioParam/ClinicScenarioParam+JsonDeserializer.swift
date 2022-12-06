//
//  ClinicScenarioParam+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension ClinicScenarioParam {
    enum ParamType: String, Decodable {
        case checkbox, select, number, text, date, hidden, currentDate = "current_date"
    }
    
    public struct JsonDeserializer {
        let type: ParamType
        let code: String
        let required: Bool
        let defaultValue: String?
        let name: String?
        let description: String?
        let value: String?
        let values: Array<ClinicScenarioParamOption.JsonDeserializer>?
    }
    
    private static func saveFromJson(_ data: JsonDeserializer, scenario: ClinicScenario, for context: NSManagedObjectContext) {
        let clinicScenarioParam = get(code: data.code, scenario: scenario, for: context) ?? ClinicScenarioParam(context: context)
        
        clinicScenarioParam.type = data.type.rawValue
        clinicScenarioParam.code = data.code
        clinicScenarioParam.required = data.required
        clinicScenarioParam.defaultValue = data.defaultValue
        clinicScenarioParam.name = data.name
        clinicScenarioParam.paramDescription = data.description
        clinicScenarioParam.value = data.value
        clinicScenarioParam.scenario = scenario
        
        if let values = data.values {
            ClinicScenarioParamOption.saveFromJson(values, param: clinicScenarioParam, for: context)
        }
    }
    
    public static func saveFromJson(_ data: [JsonDeserializer], scenario: ClinicScenario, for context: NSManagedObjectContext) {
        for clinicScenarioParamData in data {
            saveFromJson(clinicScenarioParamData, scenario: scenario, for: context)
        }
    }
}

extension ClinicScenarioParam.JsonDeserializer: Decodable {
    enum CodingKeys: String, CodingKey {
        case required
        case code
        case defaultValue = "default"
        case name
        case description
        case type
        case value
        case values
    }
    
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<ClinicScenarioParam.JsonDeserializer.CodingKeys> = try decoder.container(keyedBy: ClinicScenarioParam.JsonDeserializer.CodingKeys.self)
        self.type = try container.decode(ClinicScenarioParam.ParamType.self, forKey: ClinicScenarioParam.JsonDeserializer.CodingKeys.type)
        self.code = try container.decode(String.self, forKey: ClinicScenarioParam.JsonDeserializer.CodingKeys.code)
        self.value = (try? container.decode(String.self, forKey: ClinicScenarioParam.JsonDeserializer.CodingKeys.value)) ?? nil
        self.required = (try? container.decode(Bool.self, forKey: ClinicScenarioParam.JsonDeserializer.CodingKeys.required)) ?? false
        self.name = (try? container.decode(String.self, forKey: ClinicScenarioParam.JsonDeserializer.CodingKeys.name)) ?? nil
        self.description = (try? container.decode(String.self, forKey: ClinicScenarioParam.JsonDeserializer.CodingKeys.description)) ?? nil
        if let defaultValue = try? container.decode(Int.self, forKey: ClinicScenarioParam.JsonDeserializer.CodingKeys.defaultValue) {
            self.defaultValue = String(defaultValue)
        } else {
            self.defaultValue = nil
        }
        self.values = (try? container.decode(Array<ClinicScenarioParamOption.JsonDeserializer>.self, forKey: ClinicScenarioParam.JsonDeserializer.CodingKeys.description)) ?? nil
    }
}
