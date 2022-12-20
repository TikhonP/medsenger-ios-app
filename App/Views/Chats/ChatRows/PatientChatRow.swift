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
        HStack {
            avatarImage
                .frame(height: 70)
                .accessibilityLabel("Doctor photo")
            
            VStack(alignment: .leading) {
                HStack {
                    if contract.isConsilium {
                        Text("Consilium")
                    } else {
                        Text(contract.wrappedName)
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                    }
                    Spacer()
                    if let lastFetchedMessageSent = contract.lastFetchedMessage?.sent {
                        LastDateView(date: lastFetchedMessageSent)
                            .font(.caption)
                    }
                }
                
                Text(contract.wrappedRole)
                    .foregroundColor(.secondary)
                    .bold()
                    .padding(.bottom, 5)
                
                if let scenarioName = contract.scenarioName {
                    Text("Monitoring: \(scenarioName)")
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }
                
                if let clinic = contract.clinic {
                    Text(clinic.wrappedName)
                }
                
                clinicLogo
                    .frame(height: 80)
                    .accessibilityLabel("Clinic logo")
            }
            
            Spacer()
            
            if (contract.unread != 0) {
                MessagesBadgeView(count: Int(contract.unread), color: .accentColor.opacity(0.5))
                    .accessibilityLabel("Unread: \(Int(contract.unread))")
            }
        }
        .animation(.default, value: contract.unread)
    }
    
    var avatarImage: some View {
        ZStack {
            if let avatar = contract.avatar {
                Image(data: avatar)?
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .onAppear(perform: { chatsViewModel.getContractAvatar(contractId: Int(contract.id)) })
            }
        }
        .clipShape(Circle())
    }
    
    var clinicLogo: some View {
        ZStack {
            if let clinicLogo = contract.clinic?.logo {
                Image(data: clinicLogo)?
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .padding()
                    .onAppear(perform: {
                        chatsViewModel.getClinicLogo(contractId: Int(contract.id))
                    })
            }
        }
    }
}

#if DEBUG
struct PatientChatRow_Previews: PreviewProvider {
    static var previews: some View {
        PatientChatRow(contract: ContractPreviews.contractForPatientChatRowPreview)
            .environmentObject(ChatsViewModel())
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
#endif
