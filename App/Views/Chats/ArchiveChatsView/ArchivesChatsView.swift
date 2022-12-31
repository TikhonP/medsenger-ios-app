//
//  ArchivesChatsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ArchivesChatsView: View {
    @ObservedObject var user: User
    
    @EnvironmentObject private var chatsViewModel: ChatsViewModel
    @EnvironmentObject private var networkConnectionMonitor: NetworkConnectionMonitor
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "lastMessageTimestamp", ascending: false),
            NSSortDescriptor(key: "endDate", ascending: false),
            NSSortDescriptor(key: "unread", ascending: false),
            NSSortDescriptor(key: "id", ascending: false),
        ],
        predicate: NSPredicate(format: "archive == YES"),
        animation: .default)
    private var contracts: FetchedResults<Contract>
    
    @AppStorage(UserDefaults.Keys.userRoleKey) private var userRole: UserRole = UserDefaults.userRole
    
    @State private var searchText = ""
    var query: Binding<String> {
        Binding {
            searchText
        } set: { newValue in
            searchText = newValue
            if #available(iOS 15.0, *) {
                if newValue.isEmpty {
                    contracts.nsPredicate = NSPredicate(format: "archive == YES")
                } else {
                    contracts.nsPredicate = NSPredicate(format: "name CONTAINS %@ AND archive == YES", newValue)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            List(contracts) { contract in
                NavigationLink(destination: {
                    ChatView(contract: contract, user: user)
                }, label: {
                    switch userRole {
                    case .patient:
                        PatientChatRow(contract: contract)
                    case .doctor:
                        DoctorChatRow(contract: contract)
                    default:
                        EmptyView()
                    }
                })
            }
            .listStyle(.plain)
            .searchableIos15Only(text: query)
            .refreshableIos15Only { await chatsViewModel.getArchiveContracts(presentFailedAlert: true) }
            
            if contracts.isEmpty {
                if chatsViewModel.showArchiveContractsLoading {
                    ProgressView()
                } else {
                    EmptyArchiveChatsView()
                        .onTapGesture {
                            Task {
                                await chatsViewModel.getArchiveContracts(presentFailedAlert: true)
                            }
                        }
                }
            }
        }
        .animation(.default, value: chatsViewModel.showArchiveContractsLoading)
        .navigationTitle("ArchivesChatsView.navigationTitle")
        .onAppear {
            Task {
                await chatsViewModel.getArchiveContracts(presentFailedAlert: false)
            }
        }
        .internetOfflineWarningInBottomBar(networkMonitor: networkConnectionMonitor)
    }
}

#if DEBUG
//struct ArchivesChatsView_Previews: PreviewProvider {
//    static let persistence = PersistenceController.preview
//    
//    static var user: User = {
//        let context = persistence.container.viewContext
//        return User.createSampleUser(for: context)
//    }()
//    
//    static var previews: some View {
//        NavigationView {
//            ArchivesChatsView(user: user)
//                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//                .environmentObject(ChatsViewModel())
//        }
//    }
//}
#endif
