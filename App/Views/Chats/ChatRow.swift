//
//  ChatRow.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChatRow: View {
    let avatar: Data?
    let contractId: Int
    let name: String?
    let isOnline: Bool
    let isArchive: Bool
    
    @EnvironmentObject var chatsViewModel: ChatsViewModel
    
    var body: some View {
        HStack {
            ZStack {
                ZStack {
                    if let avatar = avatar {
                        Image(data: avatar)?
                            .resizable()
                    } else {
                        ProgressView()
                            .onAppear(perform: { chatsViewModel.getContractAvatar(contractId: contractId) })
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .padding()
                if !isArchive {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .foregroundColor(isOnline ? .green : .red)
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
                        Text(name ?? "Unknown name")
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

//struct ChatRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatRow(name: "Andreij", avatar: nil, contractId: 1)
//    }
//}
