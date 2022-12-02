//
//  Clinic+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(Clinic)
public class Clinic: NSManagedObject {
    class func get(id: Int, for context: NSManagedObjectContext) -> Clinic? {
        let fetchRequest = Clinic.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "Clinic get by id")
        return fetchedResults?.first
    }
    
    class func saveLogo(id: Int, image: Data) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            guard let clinic = get(id: id, for: context) else {
                return
            }
            clinic.logo = image
            PersistenceController.save(for: context, detailsForLogging: "Clinic save logo")
        }
    }
}

extension Clinic {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var contractsArray: [Contract] {
        let set = contracts as? Set<Contract> ?? []
        return Array(set)
    }
    
    public var agentsArray: [Agent] {
        let set = agents as? Set<Agent> ?? []
        return Array(set)
    }
    
    public var rulesArray: [ClinicRule] {
        let set = rules as? Set<ClinicRule> ?? []
        return Array(set)
    }
    
    public var classifiersArray: [ClinicClassifier] {
        let set = classifiers as? Set<ClinicClassifier> ?? []
        return Array(set)
    }
    
    public var scenariosArray: [ClinicScenario] {
        let set = scenarios as? Set<ClinicScenario> ?? []
        return Array(set)
    }
    
    public var devicesArray: [ClinicDevice] {
        let set = devices as? Set<ClinicDevice> ?? []
        return Array(set)
    }
}

// MARK: - Check JSON data logic

extension Clinic {
    struct JsonDecoderFromCheck: Decodable {
        let name: String
        let id: Int
        let video_enabled: Bool
        let esia_enabled: Bool
        let delayed_contracts_enabled: Bool
        
        let rules: Array<ClinicRule.JsonDeserializer>
        let classifiers: Array<ClinicClassifier.JsonDeserializer>
    }
    
    class func saveFromJson(_ data: JsonDecoderFromCheck, for context: NSManagedObjectContext) -> Clinic {
        let clinic = get(id: data.id, for: context) ?? Clinic(context: context)
        
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
    struct JsonDecoderRequestAsPatient: Decodable {
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
    
    class func saveFromJson(_ data: JsonDecoderRequestAsPatient, for context: NSManagedObjectContext) -> Clinic {
        let clinic = get(id: data.id, for: context) ?? Clinic(context: context)
        
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
    struct JsonDecoderRequestAsDoctor: Decodable {
        let id: Int
        let name: String
        let timezone: String
        let logo_id: Int?
        let full_logo_id: Int?
        let nonsquare_logo_id: Int?
        let video_enabled: Bool
        let phone_paid: Bool
        let phone: String
        
        let agents: Array<Agent.JsonDecoderFromClinic>
        let devices: Array<ClinicDevice.JsonDeserializer>
        let scenarios: Array<ClinicScenario.JsonDeserializer>
    }
    
    class func saveFromJson(_ data: JsonDecoderRequestAsDoctor, for context: NSManagedObjectContext) -> Clinic {
        let clinic = get(id: data.id, for: context) ?? Clinic(context: context)
        
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
        
        for agentData in data.agents {
            let agent = Agent.saveFromJson(agentData, for: context)
            if !clinic.agentsArray.contains(agent) {
                clinic.addToAgents(agent)
            }
        }
        
        ClinicScenario.saveFromJson(data.scenarios, clinic: clinic, for: context)
        ClinicDevice.saveFromJson(data.devices, clinic: clinic, for: context)
        
        return clinic
    }
}
