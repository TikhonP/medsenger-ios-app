//
//  App.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

@main
struct MedsengerApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
