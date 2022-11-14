//
//  ChatsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChatsView: View {
    @StateObject private var chatsViewModel = ChatsViewModel()
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "unread", ascending: false),
            NSSortDescriptor(key: "sortRating", ascending: false),
            NSSortDescriptor(key: "endDate", ascending: false)
        ],
        predicate: NSPredicate(format: "archive == NO"),
        animation: .default)
    private var contracts: FetchedResults<Contract>
    
    @State private var showSettingsModal: Bool = false
    @State private var showNewContractModal: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(contracts) { contract in
                    NavigationLink(destination: {
                        ChatView(contract: contract)
                    }, label: {
                        ChatRow(contract: contract)
                            .environmentObject(chatsViewModel)
                    })
                }
                
                NavigationLink(destination: {
                    ArchivesChatsView()
                        .environmentObject(chatsViewModel)
                }, label: { archiveRow })
            }
            .deprecatedRefreshable { await chatsViewModel.getContracts() }
            .listStyle(PlainListStyle())
            .navigationTitle("Chats")
            .onAppear(perform: chatsViewModel.getContracts)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettingsModal.toggle() }, label: { Image(systemName: "gear") })
                        .id(UUID())
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewContractModal.toggle() }, label: { Image(systemName: "square.and.pencil") })
                        .id(UUID())
                }
            }
            .sheet(isPresented: $showSettingsModal, content: { SettingsView() })
            .sheet(isPresented: $showNewContractModal, content: { Text("Add new contract") })
        }
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
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return ChatsView()
            .environment(\.managedObjectContext, context)
    }
}
