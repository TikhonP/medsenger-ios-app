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
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    HStack {
                        avatarImage
                            .frame(width: 60)
                            .accessibilityLabel("PatientChatRow.DoctorPhoto.accessibilityLabel")
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(contract.wrappedName)
                                .font(.headline)
                                .accessibilityAddTraits(.isHeader)
                                .padding(.trailing, 20)
                            ZStack {
                                if let clinic = contract.clinic {
                                    Text("PatientChatRow.specialityAnClinic \(contract.wrappedSpeciality) in «\(clinic.wrappedName)»", comment: "%@ в «%@»")
                                        .font(.footnote)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.bottom, 10)
                            if let scenarioName = contract.scenarioName {
                                Text(scenarioName)
                                    .font(.footnote)
                                    .bold()
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 5)
                            }
                            if let endDate = contract.endDate, let startDate = contract.startDate {
                                Text("\(startDate, formatter: DateFormatter.ddMMyyyy)–\(endDate, formatter: DateFormatter.ddMMyyyy)")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    clinicLogo
                        .frame(height: 65)
                        .accessibilityLabel("PatientChatRow.ClinicLogo.accessibilityLabel")
                }
                
                Spacer()
                if (contract.unread != 0) {
                    MessagesBadgeView(count: Int(contract.unread), color: .accentColor.opacity(0.5))
                        .accessibilityLabel("PatientChatRow.Unread.accessibilityLabel \(Int(contract.unread))")
                }
            }
            .animation(.default, value: contract.unread)
            
            if let lastMessageTimestamp = contract.lastMessageTimestamp {
                LastDateView(date: lastMessageTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
                    .onAppear {
                        Task(priority: .background) {
                            await chatsViewModel.getContractAvatar(contractId: Int(contract.id))
                        }
                    }
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
                    .onAppear {
                        guard let clinic = contract.clinic else {
                            return
                        }
                        Task(priority: .background) {
                            await chatsViewModel.getClinicLogo(contractId: Int(contract.id), clinicId: Int(clinic.id))
                        }
                    }
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
            .environment(\.locale, .init(identifier: "ru"))
    }
}
#endif
