//
//  DoctorChatRow.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct DoctorChatRow: View {
    @ObservedObject var contract: Contract
    @EnvironmentObject private var chatsViewModel: ChatsViewModel
    
    var body: some View {
        HStack {
            avatarImage
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(contract.wrappedShortName)
                        .font(.headline)
                    Spacer()
                    if let lastFetchedMessageSent = contract.lastFetchedMessage?.sent {
                        LastDateView(date: lastFetchedMessageSent)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        if let scenarioName = contract.scenarioName {
                            Text(scenarioName)
                                .font(.caption)
                                .bold()
                        }
                        if let clinic = contract.clinic {
                            Text(clinic.wrappedName)
                                .font(.caption)
                        }
                        if let endDate = contract.endDate {
                            Text("Contract \(contract.wrappedNumber). End: \(endDate, formatter: DateFormatter.ddMMyyyy)")
                                .font(.caption)
                        }
                        if (contract.complianceAvailible != 0) {
                            Text("Complience: \(contract.complianceDone) / \(contract.complianceAvailible)")
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
                    if contract.state == .warning || contract.state == .deadlined {
                        badgeView(max(Int(contract.unread), Int(contract.unanswered)), color: .red)
                    } else if (contract.unread != 0) || (contract.unanswered != 0) {
                        badgeView(max(Int(contract.unread), Int(contract.unanswered)), color: .secondary)
                    }
                }
            }
        }
//        .onAppear {
//            Messages.shared.fetchLast10Messages(contractId: Int(contract.id))
//        }
    }
    
    var avatarImage: some View {
        ZStack(alignment: .bottomTrailing) {
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
            
            if !contract.archive && contract.isOnline {
                Circle()
                    .foregroundColor(.green)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color(UIColor.systemBackground)))
                    .offset(x: -4, y: -4)
            }
        }
    }
    
//    var consiliumAvatar: some View {
//        
//    }
    
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
struct DoctorChatRow_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var contract2: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract2Archive(for: context)
    }()
    
    static var previews: some View {
        Group {
            DoctorChatRow(contract: contract1)
                .environmentObject(ChatsViewModel())
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
            
            DoctorChatRow(contract: contract2)
                .environmentObject(ChatsViewModel())
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
        }
    }
}
#endif
