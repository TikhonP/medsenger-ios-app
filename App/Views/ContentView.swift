//
//  ContentView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var contentViewModel = ContentViewModel.shared
    @StateObject private var networkConnectionMonitor = NetworkConnectionMonitor()
    
    @AppStorage(UserDefaults.Keys.userRoleKey) private var userRole: UserRole = UserDefaults.userRole
    
    @FetchRequest(sortDescriptors: [], animation: .default) private var users: FetchedResults<User>
    
    var body: some View {
        if let user = users.first {
            if userRole == .unknown {
                ChooseRoleView()
            } else {
                NavigationView {
                    ChatsView(user: user)
                }
                .environmentObject(contentViewModel)
                .environmentObject(networkConnectionMonitor)
                .onAppear(perform:  Login.shared.deauthIfTokenIsNotExists)
                .onOpenURL(perform: contentViewModel.processDeeplink)
                .fullScreenCover(isPresented: $contentViewModel.isCalling) {
                    if let videoCallContractId = contentViewModel.videoCallContractId {
                        VideoCallView(contractId: videoCallContractId, contentViewModel: contentViewModel)
                            .environmentObject(contentViewModel)
                    }
                }
            }
        } else {
            SignInView()
                .environmentObject(networkConnectionMonitor)
                .onAppear(perform: {
                    PersistenceController.clearDatabase(withUser: true)
                })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
