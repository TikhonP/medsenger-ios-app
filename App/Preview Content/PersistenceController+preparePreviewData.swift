//
//  PersistenceController+preparePreviewData.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

#if DEBUG
import Foundation
import CoreData

extension PersistenceController {
    static var preview: PersistenceController = {
        let persistenceController = PersistenceController(inMemory: true)
        let viewContext = persistenceController.container.viewContext
        preparePreviewData(for: viewContext)
        return persistenceController
    }()
    
    static func preparePreviewData(for viewContext: NSManagedObjectContext) {
        // ** Prepare all sample data for previews here ** //
        
        _ = User.createSampleUser(for: viewContext)
        Contract.createSampleContracts(for: viewContext)
        
        PersistenceController.save(for: viewContext)
    }
}
#endif
