//
//  PatientChatRow.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct PatientChatRow: View {
    @ObservedObject var contract: Contract
    @EnvironmentObject private var chatsViewModel: ChatsViewModel
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    if let avatar = contract.avatar {
                        Image(data: avatar)?
                            .resizable()
                    } else {
                        ProgressView()
                            .onAppear(perform: {
                                chatsViewModel.getContractAvatar(contractId: Int(contract.id))
                            })
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                
                ZStack {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(contract.name ?? "Unknown name")
                                .bold()
                            Spacer()
                            if let lastMessageSent = contract.lastFetchedMessage?.sent {
                                Text(lastMessageSent, formatter: DateFormatter.ddMMyyyy)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let lastMessageText = contract.lastFetchedMessage?.text {
                            HStack {
                                Text(lastMessageText)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                    .frame(height: 50, alignment: .top)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.trailing, 40)
                            }
                        }
                    }
                }
            }
            .frame(height: 80)
            
            ZStack {
                Color.secondary.opacity(0.1)
                VStack {
                    HStack {
                        Text(contract.role ?? "Unknown doctor role")
                        if let scenarioName = contract.scenarioName {
                            Text(scenarioName)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                    if let contractNumber = contract.number {
                        HStack {
                            Text("Контракт: ")
                            Text(contractNumber)
                                .foregroundColor(.secondary)
                        }
                    }
                    Text(contract.clinic?.name ?? "Unknown clinic name")
                    ZStack {
                        if let clinicLogo = contract.clinic?.logo {
                            Image(data: clinicLogo)?
                                .resizable()
                        } else {
                            ProgressView()
                                .onAppear(perform: {
                                    chatsViewModel.getClinicLogo(contractId: Int(contract.id))
                                })
                        }
                    }
//                    .frame(width: 70, height: 70)
//                    .clipShape(Circle())
                }
            }
            .frame(maxHeight: 300)
            .cornerRadius(17)
            .padding(.bottom)
        }
    }
}

struct PatientChatRow_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract2Archive(for: context)
    }()
    
    static var previews: some View {
        PatientChatRow(contract: contract)
            .environmentObject(ChatsViewModel())
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
