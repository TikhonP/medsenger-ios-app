//
//  ArchivesChatsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ArchivesChatsView: View {
    @EnvironmentObject var chatsViewModel: ChatsViewModel
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "archive == YES"), animation: .default)
    private var contracts: FetchedResults<Contract>
    
    var body: some View {
        List(contracts) { contract in
            NavigationLink(destination: {
                ChatView(contract: contract)
            }, label: {
                ChatRow(name: contract.name ?? "Failed to fetch name", avatar: contract.avatar, contractId: Int(contract.id))
            })
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Archive Chats")
        .onAppear(perform: chatsViewModel.getArchiveContracts)
    }
}

struct ArchivesChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivesChatsView()
    }
}
