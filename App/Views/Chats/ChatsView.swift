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
    
    @StateObject private var chatsViewModel = ChatsViewModel()
    
    @EnvironmentObject private var contentViewModel: ContentViewModel
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "unread", ascending: false),
            NSSortDescriptor(key: "sortRating", ascending: false),
            NSSortDescriptor(key: "endDate", ascending: false)
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
                contracts.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "name CONTAINS %@ AND archive == NO", newValue)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(contracts) { contract in
                NavigationLink(tag: Int(contract.id), selection: $chatsNavigationSelection, destination: {
                    ChatView(contract: contract, user: user)
                }, label: {
                    switch userRole {
                    case .patient:
                        PatientChatRow(contract: contract)
                            .environmentObject(chatsViewModel)
                    case .doctor:
                        DoctorChatRow(contract: contract)
                            .environmentObject(chatsViewModel)
                    default:
                        Text("Unknown user role")
                    }
                })
            }
            
            NavigationLink(tag: -1, selection: $chatsNavigationSelection, destination: {
                ArchivesChatsView(user: user)
                    .environmentObject(chatsViewModel)
            }, label: { archiveRow })
            .isDetailLink(false)
        }
        .deprecatedRefreshable { await chatsViewModel.getContracts() }
        .deprecatedSearchable(text: query)
        .listStyle(PlainListStyle())
        .navigationTitle("Chats")
        .onAppear(perform: {
            chatsViewModel.initilizeWebsockets()
            chatsViewModel.getContracts()
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if userRole == .doctor {
                    Button(action: {
                        showNewContractModal.toggle()
                    }, label: { Image(systemName: "square.and.pencil") })
                        .id(UUID())
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettingsModal.toggle() }, label: { Image(systemName: "gear") })
                    .id(UUID())
            }
        }
        .sheet(isPresented: $showSettingsModal, content: { SettingsView() })
        .sheet(isPresented: $showNewContractModal, content: { Text("Add new contract") })
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
    }
    
    var archiveRow: some View {
        HStack {
            Image(systemName: "archivebox.circle.fill")
                .resizable()
                .frame(width: 70, height: 70)
                .clipShape(Circle())
            
            ZStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Archive")
                            .bold()
                        Spacer()
                    }
                }
            }
        }
        .frame(height: 80)
    }
}

struct ChatsView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var user: User = {
        let context = persistence.container.viewContext
        return User.createSampleUser(for: context)
    }()
    
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return NavigationView {
            ChatsView(user: user)
                .environment(\.managedObjectContext, context)
        }
    }
}
