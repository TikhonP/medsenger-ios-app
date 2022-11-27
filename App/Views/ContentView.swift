//
//  ContentView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var contentViewModel = ContentViewModel()
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var users: FetchedResults<User>
    
    @AppStorage(UserDefaults.Keys.userRoleKey) var userRole: UserRole = UserDefaults.userRole
    
    var body: some View {
        if let user = users.first {
            ZStack {
                if userRole == .unknown {
                    ChooseRoleView()
                } else {
                    ZStack {
                        NavigationView {
                            ChatsView(user: user)
                        }
                        .environmentObject(contentViewModel)
                        
                        if contentViewModel.isCalling, let videoCallContractId = contentViewModel.videoCallContractId {
                            VideoCallView(contractId: videoCallContractId, contentViewModel: contentViewModel)
                                .environmentObject(contentViewModel)
                        }
                    }
                }
            }
            .onAppear(perform:  Login.shared.deauthIfTokenIsNotExists)
        } else {
            SignInView()
                .onAppear(perform: PersistenceController.clearDatabase)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
