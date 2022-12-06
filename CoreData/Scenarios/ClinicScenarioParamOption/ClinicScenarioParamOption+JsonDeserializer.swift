//
//  ClinicScenarioParamOption+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension ClinicScenarioParamOption {
    public struct JsonDeserializer: Decodable {
        let code: String
        let name: String
        let `default`: Bool
    }
    
    private static func saveFromJson(_ data: JsonDeserializer, param: ClinicScenarioParam, for context: NSManagedObjectContext) {
        let clinicScenarioParamOption = get(code: data.code, param: param, for: context) ?? ClinicScenarioParamOption(context: context)
        
        clinicScenarioParamOption.code = data.code
        clinicScenarioParamOption.name = data.name
        clinicScenarioParamOption.defaultValue = data.default
        clinicScenarioParamOption.param = param
    }
    
    public static func saveFromJson(_ data: [JsonDeserializer], param: ClinicScenarioParam, for context: NSManagedObjectContext) {
        for clinicScenarioParamOptionData in data {
            saveFromJson(clinicScenarioParamOptionData, param: param, for: context)
        }
    }
}
