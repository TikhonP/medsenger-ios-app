//
//  ContractView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ContractView: View {
    @ObservedObject private var contract: Contract
    @ObservedObject private var user: User
    
    @StateObject private var contractViewModel: ContractViewModel
    
    @EnvironmentObject private var contentViewModel: ContentViewModel
    
    @AppStorage(UserDefaults.Keys.userRoleKey) private var userRole: UserRole = UserDefaults.userRole
    
    @State private var showDevices = false
    @State private var showEditNotes = false
    @State private var showDeleteScenarioConfirmation = false
    @State private var showAvatarImage = false
    
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
            
            contractInfoSection
            
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
            if userRole == .patient, !contract.agentTasksArray.isEmpty {
                tasksForTheDay
            }
            if !contract.doctorHelpersArray.isEmpty {
                consultants
            }
            if !contract.patientHelpersArray.isEmpty {
                guardianship
            }
        }
        .refreshableIos15Only { await contractViewModel.getContracts() }
        .sheet(isPresented: $showEditNotes) {
            EditNotesView(contract: contract)
        }
        .sheet(isPresented: $contractViewModel.showChooseScenario) {
            if let clinic = contract.clinic {
                ChooseScenarioView(contract: contract, clinic: clinic)
                    .environmentObject(contractViewModel)
            }
        }
        .sheet(isPresented: $showDevices) {
            ContractDevicesView(contract: contract)
        }
    }
    
    var tasksForTheDay: some View {
        Section(header: Text("ContractView.tasksForDay.Header", comment: "Tasks for the day")) {
            ForEach(contract.agentTasksArray) { agentTask in
                HStack {
                    Text(agentTask.wrappedText)
                    Spacer()
                    if agentTask.isDone {
                        Text("ContractView.taskForDayDone", comment: "done")
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(agentTask.number) / \(agentTask.targetNumber)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    var consultants: some View {
        Section(header: Text("ContractView.Consultants.Header", comment: "Consultants")) {
            ForEach(contract.doctorHelpersArray) { doctorHelper in
                VStack(alignment: .leading) {
                    Text(doctorHelper.wrappedName)
                    Text(doctorHelper.wrappedRole)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
    
    var guardianship: some View {
        Section(header: Text("ContractView.RelativesAndCare.Header", comment: "Relatives and care")) {
            ForEach(contract.patientHelpersArray) { patientHelper in
                VStack(alignment: .leading) {
                    Text(patientHelper.wrappedName)
                    Text(patientHelper.wrappedRole)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
    
    var contractInfoSection: some View {
        Section(header: Text("ContractView.ContractInformation.Header", comment: "Contract Information")) {
            VStack(alignment: .leading) {
                Text(contract.wrappedNumber)
                Text("ContractView.contractNumber", comment: "Contract number")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            if let startDate = contract.startDate, let endDate = contract.endDate {
                VStack(alignment: .leading) {
                    Text("ContractView.fromDate \(startDate, style: .date) ContractView.toDate \(endDate, style: .date)", comment: "from %@ to %@")
                    Text("ContractView.Validity", comment: "Validity")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            ForEach(contract.paramsArray) { param in
                VStack(alignment: .leading) {
                    Text(param.wrappedValue)
                    Text(param.wrappedName)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            if let clinic = contract.clinic, clinic.phonePaid, let phoneNumber = clinic.phone, !phoneNumber.isEmpty {
                Button {
                    contractViewModel.callClinic(phone: phoneNumber)
                } label: {
                    Label("ContractView.CallTheClinic.label", systemImage: "phone.fill")
                }
            }
        }
    }
    
    var infoMaterialsAndAttachments: some View {
        Section {
            if !contract.infoMaterialsArray.isEmpty && userRole == .patient {
                NavigationLink(destination: {
                    InfoMaterialsView(contract: contract)
                }, label: {
                    Label("ContractView.InfoMaterials.label", systemImage: "info.circle.fill")
                })
            }
            NavigationLink(destination: {
                AttachmentsView(contract: contract)
            }, label: {
                Label("ContractView.Attachments.label", systemImage: "doc.fill")
            })
        }
    }
    
    var notesSection: some View {
        Section(header: Text("ContractView.notes.Header", comment: "Notes")) {
            if !contract.wrappedComments.isEmpty {
                Text(contract.wrappedComments)
            }
            Button {
                showEditNotes.toggle()
            } label: {
                if contract.wrappedComments.isEmpty {
                    Label("ContractView.AddNotes.label", systemImage: "note.text.badge.plus")
                } else {
                    Label("ContractView.EditNotes.label", systemImage: "note.text")
                }
            }
        }
    }
    
    var actionsForDoctor: some View {
        Section {
            if contract.video {
                Button {
                    contentViewModel.showCall(contractId: Int(contract.id), isCaller: true)
                } label: {
                    Label("ContractView.VideoСall.label", systemImage: "video.fill")
                }
            }
            if contract.canDecline {
                Button {
                    Task(priority: .userInitiated) {
                        await contractViewModel.declineMessages()
                    }
                } label: {
                    Label("ContractView.DismissMessages.label", systemImage: "checkmark.message.fill")
                }
            }
            if contract.isWaitingForConclusion {
                Button {
                    Task(priority: .userInitiated) {
                        await contractViewModel.concludeContract()
                    }
                } label: {
                    Label("ContractView.EndCounseling.label", systemImage: "person.crop.circle.badge.checkmark")
                }
            }
        }
        .alert(item: $contractViewModel.alert) { $0.alert }
    }
    
    var monitoringSection: some View {
        Section(header: Text("ContractView.Monitoring.Header", comment: "Monitoring")) {
            if let scenarioName = contract.scenarioName {
                Text(scenarioName)
                Button(action: {
                    showDeleteScenarioConfirmation.toggle()
                }, label: {
                    if contractViewModel.showRemoveScenarioLoading {
                        ProgressView()
                    } else {
                        Label("ContractView.DisableScenario.Label", systemImage: "trash")
                    }
                })
                .actionSheet(isPresented: $showDeleteScenarioConfirmation) {
                    ActionSheet(title: Text("ContractView.disableMonitoringAlertTitle", comment: "Are you sure you want to disable the monitoring scenario?"),
                                message: Text("ContractView.disableMonitoringAlertMessage", comment: "All intelligent agents will be disabled and the patient will no longer receive information notifications and questionnaires. If necessary, the script can be connected again."),
                                buttons: [
                                    .destructive(Text("ContractView.disableMonitoringAlertButton", comment: "Disable Scenario"), action: {
                                        Task(priority: .userInitiated) {
                                            await contractViewModel.removeScenario()
                                        }
                                    }),
                                    .cancel()
                                ])
                }
            }
            if let clinic = contract.clinic, !clinic.scenariosArray.isEmpty, !contract.archive {
                Button(action: {
                    contractViewModel.showChooseScenario.toggle()
                }, label: {
                    Label("ContractView.AssignMonitoringScenario.Label", systemImage: "doc.badge.gearshape")
                })
            }
            if !contract.archive, let clinic = contract.clinic, !clinic.devices.isEmpty {
                Button(action: {
                    showDevices.toggle()
                }, label: {
                    Label("ContractView.DevicesControl.Label", systemImage: "lightbulb")
                })
            }
        }
    }
    
    var agentActions: some View {
        Section(header: Text("ContractView.actions.Header", comment: "Actions")) {
            ForEach(contract.agentActionsArray) { agentAction in
                switch agentAction.type {
                case .url:
                    if let name = agentAction.name, let link = agentAction.apiLink {
                        Link(destination: link, label: {
                            Label(name, systemImage: "link")
                        })
                    }
                case .action:
                    Text("ContractView.AgentActionPlaceholder", comment: "Agent action")
                default:
                    if let name = agentAction.name, let link = agentAction.modalLink {
                        NavigationLink(destination: {
                            WebView(url: link, title: name)
                        }, label: {
                            Label(name, systemImage: "bolt.fill")
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
                    if contract.isConsilium {
                        if let patientAvatar = contract.patientAvatar, let doctorAvatar = contract.doctorAvatar {
                            Image(data: patientAvatar)?
                                .resizable()
                                .scaledToFit()
                                .frame(height: 95)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.systemBackground, lineWidth: 2))
                                .offset(x: -25)
                            Image(data: doctorAvatar)?
                                .resizable()
                                .scaledToFit()
                                .frame(height: 95)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.systemBackground, lineWidth: 2))
                                .offset(x: 25)
                        } else {
                            ProgressView()
                        }
                    } else {
                        if let avatarData = contract.avatar {
                            Image(data: avatarData)?
                                .resizable()
                                .scaledToFit()
                                .frame(height: 95)
                                .clipShape(Circle())
                                .onTapGesture {
                                    
                                    showAvatarImage = true
                                }
                                .fullScreenCover(isPresented: $showAvatarImage) {
                                    FullscreenImagePreview(imageData: avatarData)
                                }
                        } else {
                            ProgressView()
                        }
                    }
                }
                
                Text(contract.wrappedName)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)
                
                HStack {
                    if let role = contract.role, !role.isEmpty {
                        Text(role)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if let infoUrl = contract.infoUrl {
                        Link(destination: infoUrl) {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
            Spacer()
        }
    }
}

#if DEBUG
//struct ContractView_Previews: PreviewProvider {
//    static let persistence = PersistenceController.preview
//    
//    static var contract1: Contract = {
//        let context = persistence.container.viewContext
//        return Contract.createSampleContract1(for: context)
//    }()
//    
//    static var user: User = {
//        let context = persistence.container.viewContext
//        return User.createSampleUser(for: context)
//    }()
//    
//    static var previews: some View {
//        ContractView(contract: contract1, user: user)
//    }
//}
#endif
