//
//  App.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.10.2022.
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
