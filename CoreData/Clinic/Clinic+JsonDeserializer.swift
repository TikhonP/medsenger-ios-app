//
//  Clinic+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Check JSON data logic

extension Clinic {
    public struct JsonDecoderFromCheck: Decodable {
        let name: String
        let id: Int
        let video_enabled: Bool
        let esia_enabled: Bool
        let delayed_contracts_enabled: Bool
        
        let rules: Array<ClinicRule.JsonDeserializer>
        let classifiers: Array<ClinicClassifier.JsonDeserializer>
    }
    
    public static func saveFromJson(_ data: JsonDecoderFromCheck, for context: NSManagedObjectContext) -> Clinic {
        let clinic = (try? get(id: data.id, for: context)) ?? Clinic(context: context)
        
        clinic.name = data.name
        clinic.id = Int64(data.id)
        clinic.videoEnabled = data.video_enabled
        clinic.esiaEnabled = data.esia_enabled
        clinic.delayedContractsEnabled = data.delayed_contracts_enabled
        
        for ruleData in data.rules {
            let rule = ClinicRule.saveFromJson(ruleData, for: context)
            
            if !clinic.rulesArray.contains(rule) {
                clinic.addToRules(rule)
            }
        }
        
        for classifierData in data.classifiers {
            let classifier = ClinicClassifier.saveFromJson(classifierData, for: context)
            
            if !clinic.classifiersArray.contains(classifier) {
                clinic.addToClassifiers(classifier)
            }
        }
        
        return clinic
    }
}

// MARK: - Clinic from doctor contracts JSON data logic

extension Clinic {
    public struct JsonDecoderRequestAsPatient: Decodable {
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
    
    public static func saveFromJson(_ data: JsonDecoderRequestAsPatient, for context: NSManagedObjectContext) -> Clinic {
        let clinic = (try? get(id: data.id, for: context)) ?? Clinic(context: context)
        
        clinic.id = Int64(data.id)
        clinic.name = data.name
        clinic.timezone = data.timezone
        if let logoId = data.logo_id {
            clinic.logoId = Int64(logoId)
        }
        if let fullLogoId = data.full_logo_id {
            clinic.fullLogoId = Int64(fullLogoId)
        }
        if let nonsquareLogoId = data.nonsquare_logo_id {
            clinic.nonsquareLogoId = Int64(nonsquareLogoId)
        }
        clinic.videoEnabled = data.video_enabled
        clinic.phonePaid = data.phone_paid
        clinic.phone = data.phone
        
        return clinic
    }
}

// MARK: - Clinic from patient contract JSON data logic


extension Clinic {
    public struct JsonDecoderRequestAsDoctor: Decodable {
        let id: Int
        let name: String
        let timezone: String
        let logo_id: Int?
        let full_logo_id: Int?
        let nonsquare_logo_id: Int?
        let video_enabled: Bool
        let phone_paid: Bool
        let phone: String
        
        let agents: Array<Agent.JsonDecoderFromClinicAsAgent>
        let devices: Array<Agent.JsonDecoderFromClinicAsDevice>
        let scenarios: Array<ClinicScenario.JsonDeserializer>
    }
    
    public static func saveFromJson(_ data: JsonDecoderRequestAsDoctor, contract: Contract, for context: NSManagedObjectContext) -> Clinic {
        let clinic = (try? get(id: data.id, for: context)) ?? Clinic(context: context)
        
        clinic.id = Int64(data.id)
        clinic.name = data.name
        clinic.timezone = data.timezone
        if let logoId = data.logo_id {
            clinic.logoId = Int64(logoId)
        }
        if let fullLogoId = data.full_logo_id {
            clinic.fullLogoId = Int64(fullLogoId)
        }
        if let nonsquareLogoId = data.nonsquare_logo_id {
            clinic.nonsquareLogoId = Int64(nonsquareLogoId)
        }
        clinic.videoEnabled = data.video_enabled
        clinic.phonePaid = data.phone_paid
        clinic.phone = data.phone
        
        Agent.saveFromJson(data.agents, clinic: clinic, contract: contract, for: context)
        Agent.saveFromJson(data.devices, clinic: clinic, contract: contract, for: context)
        
        ClinicScenario.saveFromJson(data.scenarios, clinic: clinic, for: context)
        
        return clinic
    }
}
