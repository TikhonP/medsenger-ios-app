//
//  ChatRow.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChatRow: View {
    @ObservedObject var contract: Contract
    @EnvironmentObject private var chatsViewModel: ChatsViewModel
    
    var body: some View {
        HStack {
            ZStack {
                ZStack {
                    if let avatar = contract.avatar {
                        Image(data: avatar)?
                            .resizable()
                    } else {
                        ProgressView()
                            .onAppear(perform: { chatsViewModel.getContractAvatar(contractId: Int(contract.id)) })
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .padding()
                
                if !contract.archive {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .foregroundColor(contract.isOnline ? .green : .red)
                                .frame(width: 20, height: 20)
                                .padding()
                        }
                    }
                }
            }
            .frame(width: 70, height: 70)
            
            ZStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(contract.name ?? "Unknown name")
                            .bold()
                        Spacer()
                        Text("Date 123")
                    }
                    
                    HStack {
                        Text("message  cdcdcdscsdcdscsdc dscdsfjdsnfksdjnjksdnkj  sdnfkjsdnkjsdnvkjdsnv kjdsnvkjsd jdfvnkjdfv fvnjkdfnvkjdf")
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .frame(height: 50, alignment: .top)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 40)
                    }
                }
            }
        }
        .frame(height: 80)
    }
}

struct ChatRow_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var contract2: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract2(for: context)
    }()
    
    static var previews: some View {
        Group {
            ChatRow(contract: contract1)
                .environmentObject(ChatsViewModel())
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
            
            ChatRow(contract: contract2)
                .environmentObject(ChatsViewModel())
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
        }
    }
}
