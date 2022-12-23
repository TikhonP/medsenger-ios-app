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
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 0) {
                HStack {
                    avatarImage
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(contract.wrappedShortName)
                            .font(.headline)
                            .padding(.trailing, 20)
                        
                        if let scenarioName = contract.scenarioName {
                            Text(scenarioName)
                                .font(.footnote)
                                .bold()
                        }
                        if let clinic = contract.clinic {
                            Text("DoctorChatRow.contract #\(contract.wrappedNumber) in «\(clinic.wrappedName)»", comment: "Contract #\\(contract.number) in «\\(clinic.wrappedName)»")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 5)
                        }
                        if let endDate = contract.endDate, let startDate = contract.startDate {
                            Text("\(startDate, formatter: DateFormatter.ddMMyyyy)–\(endDate, formatter: DateFormatter.ddMMyyyy)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .padding(.top, 5)
                        }
                        if (contract.complianceAvailible != 0) {
                            Text("DoctorChatRow.Complience \(contract.compliencePercentage)%", comment: "Complience: %ld")
                                .font(.footnote)
                                .bold()
                                .foregroundColor(Color("medsengerBlue"))
                                .padding(.top, 5)
                        }
                        if !contract.activated {
                            Text("DoctorChatRow.notActivatedYet")
                                .font(.footnote)
                                .bold()
                                .foregroundColor(Color("notActivatedColor"))
                                .padding(.top, 5)
                        }
                    }
                    .shadow(color: shadowColor, radius:  35)
                }
                Spacer()
                if contract.state == .warning || contract.state == .deadlined {
                    MessagesBadgeView(count: max(Int(contract.unread), Int(contract.unanswered)), color: .red.opacity(0.5))
                } else if (contract.unread != 0) || (contract.unanswered != 0) {
                    MessagesBadgeView(count: max(Int(contract.unread), Int(contract.unanswered)), color: .secondary.opacity(0.5))
                }
            }
            if let lastMessageTimestamp = contract.lastMessageTimestamp {
                LastDateView(date: lastMessageTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
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
    
    func badgeView(_ count: Int, color: Color) -> some View {
        Text("\(count)")
            .padding(5)
            .background(
                Capsule()
                    .foregroundColor(color)
                    .frame(minWidth: 30)
            )
    }
    
    var shadowColor: Color {
        if !contract.activated {
            return Color("notActivatedColor")
        } else if contract.hasWarnings {
            return Color("MessageWarningColor")
        } else if contract.hasQuestions {
            return .gray
        } else {
            return .clear
        }
    }
}

#if DEBUG
struct DoctorChatRow_Previews: PreviewProvider {
    static var previews: some View {
        DoctorChatRow(contract: ContractPreviews.contractForDoctorChatRowPreview)
            .environmentObject(ChatsViewModel())
            .previewLayout(PreviewLayout.sizeThatFits)
            .environment(\.locale, .init(identifier: "ru"))
            .padding()
    }
}
#endif
