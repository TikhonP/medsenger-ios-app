//
//  ChatsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChatsView: View {
    @ObservedObject var user: User
    
    @StateObject private var chatsViewModel = ChatsViewModel.shared
    
    @EnvironmentObject private var contentViewModel: ContentViewModel
    @EnvironmentObject private var networkConnectionMonitor: NetworkConnectionMonitor
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "unread", ascending: false),
            NSSortDescriptor(key: "lastFetchedMessage.sent", ascending: false),
        ],
        predicate: NSPredicate(format: "archive == NO"),
        animation: .default)
    private var contracts: FetchedResults<Contract>
    
    @AppStorage(UserDefaults.Keys.userRoleKey) private var userRole: UserRole = UserDefaults.userRole
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showSettingsModal: Bool = false
    @State private var showNewContractModal: Bool = false
    
    @State private var chatsNavigationSelection: Int? = nil
    
    @State private var searchText = ""
    var query: Binding<String> {
        Binding {
            searchText
        } set: { newValue in
            searchText = newValue
            if #available(iOS 15.0, *) {
                if newValue.isEmpty {
                    contracts.nsPredicate = NSPredicate(format: "archive == NO")
                } else {
                    contracts.nsPredicate = NSPredicate(format: "name CONTAINS[cd] %@ AND archive == NO", newValue)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            if contracts.isEmpty {
                if chatsViewModel.showContractsLoading {
                    ProgressView()
                } else {
                    EmptyChatsView()
                        .onTapGesture {
                            chatsViewModel.getContracts(presentFailedAlert: true)
                        }
                }
            } else {
                EmptyView()
                    .alert(item: $chatsViewModel.alert) { $0.alert }
                List {
                    if userRole == .patient {
                        ComplianceView(contracts: Array(contracts), user: user)
                    }
                    
                    Section {
                        ForEach(contracts) { contract in
                            NavigationLink(tag: Int(contract.id), selection: $chatsNavigationSelection, destination: {
                                ChatView(contract: contract, user: user)
                            }, label: {
                                switch userRole {
                                case .patient:
                                    ZStack {
                                        if contract.isConsilium {
                                            ConsiliumChatRow(contract: contract)
                                        } else {
                                            PatientChatRow(contract: contract)
                                        }
                                    }
                                    .environmentObject(chatsViewModel)
                                    .contextMenu {
                                        if let phoneNumber = chatsViewModel.canCallClinicPhone(contract: contract) {
                                            Button(action: {
                                                chatsViewModel.callClinic(phone: phoneNumber)
                                            }, label: {
                                                Label("ChatsView.CallTheClinic.Label", systemImage: "phone.fill")
                                            })
                                        }
                                    }
                                    .swipeActionsIos15Only {
                                        ZStack {
                                            if let phoneNumber = chatsViewModel.canCallClinicPhone(contract: contract) {
                                                Button(action: {
                                                    chatsViewModel.callClinic(phone: phoneNumber)
                                                }, label: {
                                                    Label("ChatsView.CallTheClinic.Label", systemImage: "phone.fill")
                                                })
                                            }
                                        }
                                    }
                                case .doctor:
                                    DoctorChatRow(contract: contract)
                                        .environmentObject(chatsViewModel)
                                        .contextMenu {
                                            if contract.canDecline {
                                                Button(action: {
                                                    chatsViewModel.declineMessages(contractId: Int(contract.id))
                                                }, label: {
                                                    Label("ChatsView.DismissMessages.Label", systemImage: "checkmark.message.fill")
                                                })
                                            }
                                            if contract.isWaitingForConclusion {
                                                Button(action: {
                                                    chatsViewModel.concludeContract(contractId: Int(contract.id))
                                                }, label: {
                                                    Label("ChatsView.EndCounseling.Label", systemImage: "person.crop.circle.badge.checkmark")
                                                })
                                            }
                                        }
                                default:
                                    EmptyView()
                                }
                            })
                        }
                    }
                }
            }
        }
        .animation(.default, value: chatsViewModel.showContractsLoading)
        .animation(.default, value: contracts.isEmpty)
        .refreshableIos15Only { await chatsViewModel.getContracts(presentFailedAlert: true) }
        .searchableIos16Only(text: query)
        .listStyle(.inset)
        .navigationTitle("ChatsView.navigationTitle")
        .onAppear(perform: {
            chatsViewModel.initilizeWebsockets()
            chatsViewModel.getContracts(presentFailedAlert: false)
            contentViewModel.markChatAsClosed()
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    if userRole == .doctor {
                        Button(action: {
                            showNewContractModal.toggle()
                        }, label: { Image(systemName: "square.and.pencil") })
                        .id(UUID())
                    }
                    NavigationLink(tag: -1, selection: $chatsNavigationSelection, destination: {
                        ArchivesChatsView(user: user)
                            .environmentObject(chatsViewModel)
                    }, label: { Image(systemName: "archivebox") })
                    .isDetailLink(false)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettingsModal.toggle() }, label: { Image(systemName: "gear") })
                    .id(UUID())
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if scenePhase == .inactive {
                Websockets.shared.createUrlSession()
            }
        }
        .onChange(of: contentViewModel.openChatContractId, perform: { newContractId in
            if let newContractId = newContractId {
                chatsNavigationSelection = newContractId
            }
        })
        .sheet(isPresented: $showNewContractModal, content: { AddContractView() })
        .sheet(isPresented: $showSettingsModal, content: { SettingsView() })
        .internetOfflineWarningInBottomBar(networkMonitor: networkConnectionMonitor)
    }
}

#if DEBUG
struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDefaults.userRole = .patient
        return NavigationView {
            ChatsView(user: UserPreview.userForChatsViewPreview)
                .environment(\.managedObjectContext, UserPreview.context)
                .environmentObject(ContentViewModel())
        }
    }
}
#endif
