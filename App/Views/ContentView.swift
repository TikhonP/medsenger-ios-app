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
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        if let user = users.first {
            if userRole == .unknown {
                ChooseRoleView()
                    .transition(.opacity)
            } else {
                Group {
                    if #available(iOS 16.0, *) {
                        NavigationStack {
                            ChatsView(user: user)
                        }
                    } else {
                        NavigationView {
                            ChatsView(user: user)
                        }
                        .navigationViewStyle(.stack)
                    }
                }
                .transition(.opacity)
                .environmentObject(contentViewModel)
                .environmentObject(networkConnectionMonitor)
                .onAppear {
                    Task(priority: .background) {
                        await (Login.deauthIfTokenIsNotExists(), PushNotifications.onChatsViewAppear())
                    }
                    Websockets.shared.createUrlSession()
                }
                .onChange(of: scenePhase) { newPhase in
                    if scenePhase == .inactive {
                        Websockets.shared.createUrlSession()
                    }
                }
                .onOpenURL(perform: {
                    contentViewModel.processDeeplink($0)
                })
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
                .transition(.opacity)
                .onAppear(perform: {
                    Task(priority: .background) {
                        try? await PersistenceController.clearDatabase(withUser: true)
                    }
                })
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
