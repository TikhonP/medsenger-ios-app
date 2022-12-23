//
//  Clinic+Preview.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 15.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

#if DEBUG
import CoreData

struct ClinicPreviews {
    static let context = PersistenceController.preview.container.viewContext
    
    static func createSampleClinic(
        name: String,
        videoEnabled: Bool,
        logo: Data?,
        for viewContext: NSManagedObjectContext
    ) -> Clinic {
        let clinic = Clinic(context: viewContext)
        
        clinic.id = Int64.random(in: 0...1000)
        clinic.name = name
        clinic.videoEnabled = videoEnabled
        clinic.esiaEnabled = false
        clinic.delayedContractsEnabled = false
        clinic.logo = logo
        
        return clinic
    }
}
#endif
