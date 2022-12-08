//
//  ContractView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ContractView: View {
    let contract: Contract
    let user: User
    
    @StateObject private var contractViewModel: ContractViewModel
    
    @EnvironmentObject private var contentViewModel: ContentViewModel
    
    @AppStorage(UserDefaults.Keys.userRoleKey) var userRole: UserRole = UserDefaults.userRole
    
    @State private var showDevices = false
    @State private var showEditNotes = false
    @State private var showDeleteScenarioConfirmation = false
    
    init(contract: Contract, user: User) {
        self.contract = contract
        self.user = user
        _contractViewModel = StateObject(wrappedValue: ContractViewModel(contractId: Int(contract.id)))
    }
    
    var body: some View {
        Form {
            Section {
                personData
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            if userRole == .doctor {
                actionsForDoctor
                if let clinic = contract.clinic, !clinic.scenariosArray.isEmpty, !contract.archive {
                    monitoringSection
                }
                notesSection
            }
            
            infoMaterialsAndAttachments
            
            if !contract.agentActionsArray.isEmpty {
                agentActions
            }
        }
        .sheet(isPresented: $showEditNotes) {
            EditNotesView(contract: contract)
        }
        .sheet(isPresented: $contractViewModel.showChooseScenario) {
            if let clinic = contract.clinic {
                ChooseScenarioView(contract: contract, clinic: clinic)
                    .environmentObject(contentViewModel)
            }
        }
        .sheet(isPresented: $showDevices) {
            ContractDevicesView(contract: contract)
        }
    }
    
    var infoMaterialsAndAttachments: some View {
        Section {
            if !contract.infoMaterialsArray.isEmpty && userRole == .patient {
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
    }
    
    var notesSection: some View {
        Section(header: Text("Notes")) {
            if !contract.wrappedComments.isEmpty {
                Text(contract.wrappedComments)
            }
            Button(action: {
                showEditNotes.toggle()
            }, label: {
                if contract.wrappedComments.isEmpty {
                    Label("Add Notes", systemImage: "note.text.badge.plus")
                } else {
                    Label("Edit Notes", systemImage: "note.text")
                }
            })
        }
    }
    
    var actionsForDoctor: some View {
        Section {
            if contract.video {
                Button(action: {
                    contentViewModel.showCall(contractId: Int(contract.id), isCaller: true)
                }, label: {
                    Label("Video call", systemImage: "video.fill")
                })
            }
            if contract.canDecline {
                Button(action: {
                    contractViewModel.declineMessages()
                }, label: {
                    Label("Decline Messages", systemImage: "checkmark.message.fill")
                })
            }
            if contract.isWaitingForConclusion {
                Button(action: {
                    contractViewModel.concludeContract()
                }, label: {
                    Label("End Counseling", systemImage: "person.crop.circle.badge.checkmark")
                })
            }
        }
    }
    
    var monitoringSection: some View {
        Section(header: Text("Monitoring")) {
            if let scenarioName = contract.scenarioName {
                Text(scenarioName)
                Button(action: {
                    showDeleteScenarioConfirmation.toggle()
                }, label: {
                    if contractViewModel.showRemoveScenarioLoading {
                        ProgressView()
                    } else {
                        Label("Disable Scenario", systemImage: "trash")
                    }
                })
                .actionSheet(isPresented: $showDeleteScenarioConfirmation) {
                    ActionSheet(title: Text("Are you sure you want to disable the monitoring script?"),
                                message: Text("All intelligent agents will be disabled and the patient will no longer receive information notifications and questionnaires. If necessary, the script can be connected again."),
                                buttons: [
                                    .destructive(Text("Disable Scenario"), action: contractViewModel.removeScenario),
                                    .cancel()
                                ])
                }
            }
            if let clinic = contract.clinic, !clinic.scenariosArray.isEmpty, !contract.archive {
                Button(action: {
                    contractViewModel.showChooseScenario.toggle()
                }, label: {
                    Label("Choose Monitoring Scenario", systemImage: "doc.badge.gearshape")
                })
            }
            if !contract.archive, let clinic = contract.clinic, !clinic.devices.isEmpty {
                Button(action: {
                    showDevices.toggle()
                }, label: {
                    Label("Devices Control", systemImage: "lightbulb")
                })
            }
        }
    }
    
    var agentActions: some View {
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
                            WebView(url: link, name: name)
                        }, label: {
                            Label(name, systemImage: "person.icloud.fill")
                        })
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
