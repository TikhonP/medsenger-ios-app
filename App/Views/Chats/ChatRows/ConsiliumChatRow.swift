//
//  ConsiliumChatRow.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ConsiliumChatRow: View {
    @ObservedObject var contract: Contract
    @EnvironmentObject private var chatsViewModel: ChatsViewModel
    
    var body: some View {
        HStack {
            consiliumAvators
                .frame(width: 70)
                .accessibilityLabel("Doctor and patient photo")
            
            VStack(alignment: .leading) {
                HStack {
                    Text(contract.wrappedName)
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    if let lastFetchedMessageSent = contract.lastFetchedMessage?.sent {
                        LastDateView(date: lastFetchedMessageSent)
                            .font(.caption)
                    }
                }
                
                Text("Doctor: \(contract.wrappedDoctorName)")
                Text("You: \(contract.wrappedRole)")
                    .padding(.bottom, 5)

                if let scenarioName = contract.scenarioName {
                    Text("Monitoring: \(scenarioName)")
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }
                
                if let clinic = contract.clinic {
                    Text(clinic.wrappedName)
                }
            }
            
            Spacer()
            
            if (contract.unread != 0) {
                MessagesBadgeView(count: Int(contract.unread), color: .accentColor.opacity(0.5))
                    .accessibilityLabel("Unread: \(Int(contract.unread))")
            }
        }
        .animation(.default, value: contract.unread)
    }
    
    var consiliumAvators: some View {
        ZStack {
            if let patientAvatar = contract.`patientAvatar`, let doctorAvatar = contract.doctorAvatar {
                Image(data: patientAvatar)?
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .offset(y: -25)
                Image(data: doctorAvatar)?
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(UIColor.systemBackground), lineWidth: 2))
                    .offset(y: 25)
            } else {
                ProgressView()
                    .padding()
                    .onAppear(perform: { chatsViewModel.getContractAvatar(contractId: Int(contract.id)) })
            }
        }
    }
}

#if DEBUG
struct ConsiliumChatRow_Previews: PreviewProvider {
    static var previews: some View {
        ConsiliumChatRow(contract: ContractPreviews.contractForConsiliumChatRowPreview)
            .environmentObject(ChatsViewModel())
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
#endif
