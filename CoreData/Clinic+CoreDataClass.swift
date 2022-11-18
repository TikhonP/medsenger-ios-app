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
    private class func get(id: Int, context: NSManagedObjectContext) -> Clinic? {
        do {
            let fetchRequest = Clinic.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            let fetchedResults = try context.fetch(fetchRequest)
            if let clinic = fetchedResults.first {
                return clinic
            }
            return nil
        } catch {
            print("Get `Clinic` with id: \(id), core data task failed: ", error.localizedDescription)
            return nil
        }
    }
    
    class func saveLogo(id: Int, image: Data) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            guard let clinic = get(id: id, context: context) else {
                return
            }
            clinic.logo = image
            PersistenceController.save(context: context)
        }
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
    
    class func saveFromJson(data: JsonDecoderFromCheck, context: NSManagedObjectContext) -> Clinic {
        let clinic = {
            guard let clinic = get(id: data.id, context: context) else {
                return Clinic(context: context)
            }
            return clinic
        }()
        
        clinic.name = data.name
        clinic.id = Int64(data.id)
        clinic.videoEnabled = data.video_enabled
        clinic.esiaEnabled = data.esia_enabled
        clinic.delayedContractsEnabled = data.delayed_contracts_enabled
        
        PersistenceController.save(context: context)
        
        for ruleData in data.rules {
            let rule = ClinicRule.saveFromJson(data: ruleData, context: context)
            
            if let isExist = clinic.rules?.contains(rule), !isExist {
                clinic.addToRules(rule)
            }
        }
        
        for classifierData in data.classifiers {
            let classifier = ClinicClassifier.saveFromJson(data: classifierData, context: context)
            
            if let isExist = clinic.classifiers?.contains(classifier), !isExist {
                clinic.addToClassifiers(classifier)
            }
        }
        
        PersistenceController.save(context: context)
        
        return clinic
    }
}

// MARK: - Clinic from contracts JSON data logic

extension Clinic {
    struct JsonDecoderFromContract: Decodable {
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
    
    class func saveFromJson(data: JsonDecoderFromContract, context: NSManagedObjectContext) -> Clinic {
        let clinic = {
            guard let clinic = get(id: data.id, context: context) else {
                return Clinic(context: context)
            }
            return clinic
        }()
        
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
        
        PersistenceController.save(context: context)
        
        return clinic
    }
}
