//
//  ChatsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChatsView: View {
    @StateObject var chatsViewModel = ChatsViewModel()
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "archive == NO"), animation: .default)
    private var contracts: FetchedResults<UserDoctorContract>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(contracts) { contract in
                    ChatRow(name: contract.name ?? "Failed to fetch name", avatar: contract.avatar, contractId: Int(contract.contract))
                        .environmentObject(chatsViewModel)
                }
                
                NavigationLink(destination: {
                    ArchivesChatsView()
                        .environmentObject(chatsViewModel)
                }, label: { archiveRow })
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Chats")
        }
        .onAppear(perform: chatsViewModel.getContracts)
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
//                        Text("Date 123")
                    }
                    
//                    HStack {
//                        Text("message  cdcdcdscsdcdscsdc dscdsfjdsnfksdjnjksdnkj  sdnfkjsdnkjsdnvkjdsnv kjdsnvkjsd jdfvnkjdfv fvnjkdfnvkjdf")
//                            .foregroundColor(.gray)
//                            .lineLimit(2)
//                            .frame(height: 50, alignment: .top)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.trailing, 40)
//                    }
                }
            }
        }
        .frame(height: 80)
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}
