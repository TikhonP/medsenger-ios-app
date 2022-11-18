//
//  Clinic+Preview.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 15.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData
import UIKit

extension Clinic {
    static func createSampleClinic(for viewContext: NSManagedObjectContext) -> Clinic {
        let clinic = Clinic(context: viewContext)
        
        clinic.name = "Клиника практологии доктора Изюмского"
        clinic.id = 456
        clinic.videoEnabled = false
        clinic.esiaEnabled = false
        clinic.delayedContractsEnabled = false
        
        if let img = UIImage(named: "UserAvatarExample") {
            guard let data = img.jpegData(compressionQuality: 1) else { return clinic }
            clinic.logo = data
        }

        return clinic
    }
}
