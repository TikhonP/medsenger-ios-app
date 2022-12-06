//
//  Agent+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension Agent {
    public struct JsonDecoderRequestAsPatient: Decodable {
        let id: Int
        let name: String
        let description: String
        let open_settings_in_blank: Bool
    }
    
    private static func saveFromJson(_ data: JsonDecoderRequestAsPatient, contract: Contract, for context: NSManagedObjectContext) {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.agentDescription = data.description
        agent.name = data.name
//        agent.isDevice = false
        contract.addToAgents(agent)
    }
    
    public static func saveFromJson(_ data: [JsonDecoderRequestAsPatient], contract: Contract, for context: NSManagedObjectContext) {
        for agentData in data {
            saveFromJson(agentData, contract: contract, for: context)
        }
    }
}

extension Agent {
    public struct JsonDecoderRequestAsDoctor: Decodable {
        let id: Int
        let name: String
        let description: String
        let open_settings_in_blank: Bool
        let settings_link: URL
    }
    
    private static func saveFromJson(_ data: JsonDecoderRequestAsDoctor, contract: Contract, for context: NSManagedObjectContext) {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.agentDescription = data.description
        agent.name = data.name
//        agent.isDevice = false
        contract.addToAgents(agent)
    }
    
    public static func saveFromJson(_ data: [JsonDecoderRequestAsDoctor], contract: Contract, for context: NSManagedObjectContext) {
        for agentData in data {
            saveFromJson(agentData, contract: contract, for: context)
        }
    }
}

// MARK: - Deserialize from `agents` from clinic in contract request as Doctor

extension Agent {
    public struct JsonDecoderFromClinicAsAgent: Decodable {
        let id: Int
        let name: String
        let description: String
        let is_enabled: Bool
    }
    
    private static func saveFromJson(_ data: JsonDecoderFromClinicAsAgent, clinic: Clinic, contract: Contract, for context: NSManagedObjectContext) {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.agentDescription = data.description
        agent.name = data.name
        agent.isDevice = false
        agent.addToClinics(clinic)
        if data.is_enabled {
            agent.addToEnabledContracts(contract)
        } else {
            agent.removeFromEnabledContracts(contract)
        }
    }
    
    public static func saveFromJson(_ data: [JsonDecoderFromClinicAsAgent], clinic: Clinic, contract: Contract, for context: NSManagedObjectContext) {
        for agentData in data {
            saveFromJson(agentData, clinic: clinic, contract: contract, for: context)
        }
    }
}

// MARK: - Deserialize from `devices` from clinic in contract request as Doctor

extension Agent {
    public struct JsonDecoderFromClinicAsDevice: Decodable {
        let id: Int
        let name: String
        let description: String
        let is_enabled: Bool
    }
    
    private static func saveFromJson(_ data: JsonDecoderFromClinicAsDevice, clinic: Clinic, contract: Contract, for context: NSManagedObjectContext) {
        let agent = get(id: data.id, for: context) ?? Agent(context: context)
        
        agent.id = Int64(data.id)
        agent.name = data.name
        agent.agentDescription = data.description
        agent.isDevice = true
        agent.addToClinics(clinic)
        if data.is_enabled {
            agent.addToEnabledContracts(contract)
        } else {
            agent.removeFromEnabledContracts(contract)
        }
    }
    
    public static func saveFromJson(_ data: [JsonDecoderFromClinicAsDevice], clinic: Clinic, contract: Contract, for context: NSManagedObjectContext) {
        for clinicDeviceData in data {
            saveFromJson(clinicDeviceData, clinic: clinic, contract: contract, for: context)
        }
    }
}
