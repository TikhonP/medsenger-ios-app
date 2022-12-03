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
    
    @EnvironmentObject private var contentViewModel: ContentViewModel

    @FetchRequest(
        sortDescriptors: [
//            NSSortDescriptor(key: "lastFetchedMessage.sent", ascending: false),
            NSSortDescriptor(key: "endDate", ascending: false)
        ],
        predicate: NSPredicate(format: "archive == YES"),
        animation: .default)
    private var contracts: FetchedResults<Contract>
    
    @AppStorage(UserDefaults.Keys.userRoleKey) var userRole: UserRole = UserDefaults.userRole
    
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
            if contracts.isEmpty {
                EmptyArchiveChatsView()
            } else {
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
                            Text("Unknown user role")
                        }
                    })
                }
            }
        }
        .deprecatedSearchable(text: query)
        .deprecatedRefreshable { await chatsViewModel.getArchiveContracts() }
        .listStyle(PlainListStyle())
        .navigationTitle("Archive Chats")
        .onAppear(perform: chatsViewModel.getArchiveContracts)
    }
}

struct ArchivesChatsView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var user: User = {
        let context = persistence.container.viewContext
        return User.createSampleUser(for: context)
    }()
    
    static var previews: some View {
        NavigationView {
            ArchivesChatsView(user: user)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(ChatsViewModel())
        }
    }
}
