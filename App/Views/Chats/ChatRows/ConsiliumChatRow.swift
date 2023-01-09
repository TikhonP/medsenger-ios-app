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
    
    @State private var timeBadgeWidth: CGFloat = .zero
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                consiliumAvators
                    .frame(width: 60)
                    .accessibilityLabel("ConsiliumChatRow.doctorAndPatientPhoto.accessibilityLabel")
                
                VStack(alignment: .leading) {
                    Text(contract.wrappedName)
                        .font(.headline)
                        .padding(.trailing, timeBadgeWidth)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("ConsiliumChatRow.Doctor: \(contract.wrappedDoctorName)", comment: "Doctor: %@")
                    Text("ConsiliumChatRow.you \(contract.wrappedRole)", comment: "You: %@")
                        .padding(.bottom, 5)
                    
                    if let scenarioName = contract.scenarioName {
                        Text("ConsiliumChatRow.Monitoring: \(scenarioName)", comment: "Monitoring: %@")
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
                        .accessibilityLabel("ConsiliumChatRow.unread.accessibilityLabel \(Int(contract.unread))")
                }
            }
            .animation(.default, value: contract.unread)
            
            if let lastMessageTimestamp = contract.lastMessageTimestamp {
                LastDateView(date: lastMessageTimestamp, width: $timeBadgeWidth)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var consiliumAvators: some View {
        ZStack {
            if let patientAvatar = contract.patientAvatar, let doctorAvatar = contract.doctorAvatar {
                Image(data: patientAvatar)?
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.systemBackground, lineWidth: 2))
                    .offset(y: -25)
                Image(data: doctorAvatar)?
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.systemBackground, lineWidth: 2))
                    .offset(y: 25)
            } else {
                ProgressView()
                    .padding()
                    .onAppear(perform: {
                        Task(priority: .background) {
                            await chatsViewModel.getContractAvatar(contractId: Int(contract.id))
                        }
                    })
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
