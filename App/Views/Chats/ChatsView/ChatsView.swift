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
            NSSortDescriptor(key: "lastFetchedMessage.sent", ascending: false),
            NSSortDescriptor(key: "unread", ascending: false)
        ],
        predicate: NSPredicate(format: "archive == NO"),
        animation: .default)
    private var contracts: FetchedResults<Contract>
    
    @AppStorage(UserDefaults.Keys.userRoleKey) var userRole: UserRole = UserDefaults.userRole
    
    @Environment(\.scenePhase) var scenePhase
    
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
                            chatsViewModel.getContracts()
                        }
                }
            } else {
                List {
                    if userRole == .patient && (tasksTotalToday != 0 || tasksTotalThisWeek != 0) {
                        Section(header: Text("compliance")) {
                            VStack {
                                Text("Today: \(tasksCompletedToday) / \(tasksTotalToday)")
                                Text("Today: \(tasksTotalThisWeek) / \(tasksTotalThisWeek)")
                            }
                        }
                    }
                    
                    Section {
                        ForEach(contracts) { contract in
                            NavigationLink(tag: Int(contract.id), selection: $chatsNavigationSelection, destination: {
                                ChatView(contract: contract, user: user)
                            }, label: {
                                switch userRole {
                                case .patient:
                                    PatientChatRow(contract: contract)
                                        .environmentObject(chatsViewModel)
                                        .contextMenu {
                                            if let phoneNumber = contract.clinic?.phone {
                                                Button(action: {
                                                    let telephone = "tel://"
                                                    let formattedString = telephone + phoneNumber
                                                    guard let url = URL(string: formattedString) else { return }
                                                    UIApplication.shared.open(url)
                                                }, label: {
                                                    Label("Call the Clinic", systemImage: "phone.fill")
                                                })
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
                                                    Label("Dismiss Messages", systemImage: "checkmark.message.fill")
                                                })
                                            }
                                            if contract.isWaitingForConclusion {
                                                Button(action: {
                                                    chatsViewModel.concludeContract(contractId: Int(contract.id))
                                                }, label: {
                                                    Label("End Counseling", systemImage: "person.crop.circle.badge.checkmark")
                                                })
                                            }
                                        }
                                default:
                                    Text("Unknown user role")
                                }
                            })
                        }
                    }
                }
            }
        }
        .animation(.default, value: chatsViewModel.showContractsLoading)
        .animation(.default, value: contracts.isEmpty)
        .refreshableIos15Only { await chatsViewModel.getContracts() }
        .searchableIos16Only(text: query)
        .listStyle(.inset)
        .navigationTitle("Consultations")
        .onAppear(perform: {
            chatsViewModel.initilizeWebsockets()
            chatsViewModel.getContracts()
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
    
    var tasksTotalToday: Int {
        var total = 0
        for contract in contracts {
            for agentTask in contract.agentTasksArray {
                total += Int(agentTask.targetNumber)
            }
        }
        return total
    }
    
    var tasksCompletedToday: Int {
        var total = 0
        for contract in contracts {
            for agentTask in contract.agentTasksArray {
                total += Int(agentTask.number)
            }
        }
        return total
    }
    
    var tasksTotalThisWeek: Int {
        var total = 0
        for contract in contracts {
            total += Int(contract.complianceAvailible)
        }
        return total
    }
    
    var tasksCompletedThisWeek: Int {
        var total = 0
        for contract in contracts {
            total += Int(contract.complianceDone)
        }
        return total
    }
}

#if DEBUG
struct ChatsView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var user: User = {
        let context = persistence.container.viewContext
        return User.createSampleUser(for: context)
    }()
    
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        _ = Contract.createSampleContract1(for: context)
        UserDefaults.userRole = .patient
        return NavigationView {
            ChatsView(user: user)
                .environment(\.managedObjectContext, context)
                .environmentObject(ContentViewModel())
        }
    }
}
#endif
