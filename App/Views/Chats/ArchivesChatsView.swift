//
//  ArchivesChatsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ArchivesChatsView: View {
    @EnvironmentObject private var chatsViewModel: ChatsViewModel
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "unread", ascending: false),
            NSSortDescriptor(key: "sortRating", ascending: false),
            NSSortDescriptor(key: "endDate", ascending: false)
        ],
        predicate: NSPredicate(format: "archive == YES"),
        animation: .default)
    private var contracts: FetchedResults<Contract>
    
    var body: some View {
        List(contracts) { contract in
            NavigationLink(destination: {
                ChatView(contract: contract)
            }, label: {
                ChatRow(contract: contract)
            })
        }
        .deprecatedRefreshable { await chatsViewModel.getArchiveContracts() }
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
