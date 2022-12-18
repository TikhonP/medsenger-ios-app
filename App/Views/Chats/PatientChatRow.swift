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
                avatarImage
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(contract.wrappedShortName)
                            .bold()
                        Spacer()
                        if let lastFetchedMessageSent = contract.lastFetchedMessage?.sent {
                            LastDateView(date: lastFetchedMessageSent)
                                .font(.caption)
                        }
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            if let clinic = contract.clinic {
                                Text(clinic.wrappedName)
                                    .font(.caption)
                            }
                            if let endDate = contract.endDate {
                                Text("Contract \(contract.wrappedNumber). End: \(endDate, formatter: DateFormatter.ddMMyyyy)")
                                    .font(.caption)
                            }
                            if let text = contract.lastFetchedMessage?.text {
                                Text(text)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.trailing, 40)
                            }
                        }
                        Spacer()
                        if (contract.unread != 0) {
                            badgeView(max(Int(contract.unread), Int(contract.unanswered)), color: .secondary)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(contract.wrappedRole)
                if let scenarioName = contract.scenarioName {
                    Text(scenarioName)
                        .foregroundColor(.secondary)
                }
                
                if let contractNumber = contract.number {
                    HStack {
                        Text("Contract: ")
                        Text(contractNumber)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            clinicLogo
                .frame(height: 70)
        }
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
                    .cornerRadius(10)
            } else {
                ProgressView()
                    .onAppear(perform: {
                        chatsViewModel.getClinicLogo(contractId: Int(contract.id))
                    })
            }
        }
    }
    
    func badgeView(_ count: Int, color: Color) -> some View {
        Text("\(count)")
            .padding(5)
            .background(
                Capsule()
                    .foregroundColor(color)
                    .frame(minWidth: 30)
            )
    }
}

#if DEBUG
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
#endif
