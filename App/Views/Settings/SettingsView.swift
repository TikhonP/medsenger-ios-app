//
//  SettingsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var settingsViewModel = SettingsViewModel()
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var users: FetchedResults<User>
    
    var body: some View {
        ZStack {
            if users.first != nil {
                ProfileDataView()
                    .environmentObject(settingsViewModel)
            } else {
                Text("Failed to fetch user")
            }
        }
        .onAppear(perform: settingsViewModel.updateProfile)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
