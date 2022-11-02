//
//  Clinic.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 28.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension Clinic {
    private static func getOrCreate(medsengerId: Int, context: NSManagedObjectContext) -> Clinic {
        do {
            let fetchRequest = Clinic.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "medsengerId == %ld", medsengerId)
            let fetchedResults = try context.fetch(fetchRequest)
            if let clinic = fetchedResults.first {
                return clinic
            }
            return Clinic(context: context)
        }
        catch {
            print("Fetch core data task failed: ", error)
            return Clinic(context: context)
        }
    }
    
    class func saveFromCheck(_ clinic: ClinicDataResponse) {
        let context = PersistenceController.shared.container.viewContext
        let clinicModel = getOrCreate(medsengerId: clinic.id, context: context)
        
        clinicModel.name = clinic.name
        clinicModel.medsengerId = Int64(clinic.id)
        clinicModel.videoEnabled = clinic.video_enabled
        clinicModel.esiaEnabled = clinic.esia_enabled
        clinicModel.delayedContractsEnabled = clinic.delayed_contracts_enabled
        
        for rule in clinic.rules {
            let ruleModel = ClinicRule(context: context)
            ruleModel.name = rule.name
            ruleModel.medsengerId = Int64(rule.id)
        }
        
        for classifier in clinic.classifiers {
            let classifierModel = ClinicClassifier(context: context)
            classifierModel.name = classifier.name
            classifierModel.medsengerId = Int64(classifier.id)
        }
        
        PersistenceController.save(context: context)
    }
    
    class func saveFromContracts(_ clinic: ClinicDoctorContract, context: NSManagedObjectContext) -> Clinic {
        let clinicModel = getOrCreate(medsengerId: clinic.id, context: context)
        
        clinicModel.medsengerId = Int64(clinic.id)
        clinicModel.name = clinic.name
        clinicModel.timezone = clinic.timezone
        if let logoId = clinic.logo_id {
            clinicModel.logoId = Int64(logoId)
        }
        if let fullLogoId = clinic.full_logo_id {
            clinicModel.fullLogoId = Int64(fullLogoId)
        }
        if let nonsquareLogoId = clinic.nonsquare_logo_id {
            clinicModel.nonsquareLogoId = Int64(nonsquareLogoId)
        }
        clinicModel.videoEnabled = clinic.video_enabled
        clinicModel.phonePaid = clinic.phone_paid
        clinicModel.phone = clinic.phone
        
        return clinicModel
    }
}
