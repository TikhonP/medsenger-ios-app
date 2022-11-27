//
//  ContractView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ContractView: View {
    @ObservedObject var contract: Contract
    @ObservedObject var user: User
    
    @EnvironmentObject private var contentViewModel: ContentViewModel
    
    var body: some View {
        Form {
            Section {
                personData
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            if contract.video {
                Section {
                    Button(action: startCall, label: {
                        Label("Video call", systemImage: "video.fill")
                    })
                }
            }
            
            Section {
                if !contract.infoMaterialsArray.isEmpty {
                    NavigationLink(destination: {
                        InfoMaterialsView(contract: contract)
                    }, label: {
                        Label("Info materials", systemImage: "info.circle.fill")
                    })
                }
                NavigationLink(destination: {
                    AttachmentsView(contract: contract)
                }, label: {
                    Label("Attachments", systemImage: "doc.fill")
                })
            }
            
            if !contract.agentActionsArray.isEmpty {
                Section(header: Text("Agent Actions")) {
                    ForEach(contract.agentActionsArray) { agentAction in
                        switch agentAction.type {
                        case .url:
                            if let name = agentAction.name, let link = agentAction.apiLink {
                                Link(destination: link, label: {
                                    Label(name, systemImage: "person.icloud.fill")
                                })
                            }
                        case .action:
                            Text("Action")
                        default:
                            if let name = agentAction.name, let link = agentAction.modalLink {
                                NavigationLink(destination: {
                                    AgentActionView(url: link, name: name)
                                    //                                        Text("sdfghj")
                                }, label: {
                                    Label(name, systemImage: "person.icloud.fill")
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    var personData: some View {
        HStack {
            Spacer()
            VStack {
                ZStack {
                    if let avatarData = contract.avatar {
                        Image(data: avatarData)?
                            .resizable()
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 95, height: 95)
                .clipShape(Circle())
                
                HStack {
                    Text(contract.name ?? "Data reading error")
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    if let infoUrl = contract.infoUrl {
                        Link(destination: infoUrl) {
                            Image(systemName: "link.circle.fill")
                                .font(.largeTitle)
                        }
                    }
                }
                
                if let role = contract.role, !role.isEmpty {
                    Text(role)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
    }
    
    func startCall() {
        contentViewModel.videoCallContractId = Int(contract.id)
        contentViewModel.isCalling = true
    }
}

struct ContractView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var user: User = {
        let context = persistence.container.viewContext
        return User.createSampleUser(for: context)
    }()
    
    static var previews: some View {
        ContractView(contract: contract1, user: user)
    }
}
