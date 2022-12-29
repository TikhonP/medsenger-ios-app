//
//  ContractDevicesView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

class DeviceNode: ObservableObject, Identifiable {
    @Published var isEnabled: Bool
    
    let id: Int
    let name: String
    let description: String
    
    init(_ device: Agent, isEnabled: Bool) {
        self.name = device.wrappedName
        self.description = device.wrappedDescription
        self.id = Int(device.id)
        self.isEnabled = isEnabled
    }
}

@MainActor
final class ContractDevicesViewModel: ObservableObject {
    @Published var devicesAsNodes = [DeviceNode]()
    @Published var showLoading = false
    
    let contract: Contract
    
    init(contract: Contract) {
        self.contract = contract
        guard let clinic = contract.clinic else {
            return
        }
        let contractDevices = contract.devices
        for device in clinic.devices {
            devicesAsNodes.append(DeviceNode(device, isEnabled: contractDevices.contains(device)))
        }
    }
    
    func save() async -> Bool {
        showLoading = true
        do {
            try await DoctorActions.deviceState(devices: devicesAsNodes, contractId: Int(contract.id))
            showLoading = false
            return true
        } catch {
            showLoading = false
            return false
        }
    }
}

struct DeviceNodeView: View {
    @ObservedObject var deviceNode: DeviceNode
    
    var body: some View {
        Section(footer: Text(deviceNode.description)) {
            Toggle(isOn: $deviceNode.isEnabled, label: {
                Text(deviceNode.name)
            })
        }
    }
}

struct ContractDevicesView: View {
    @ObservedObject var contract: Contract
    
    @MainActor @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var contractDevicesViewModel: ContractDevicesViewModel
    
    init(contract: Contract) {
        self.contract = contract
        _contractDevicesViewModel = StateObject(wrappedValue: ContractDevicesViewModel(contract: contract))
    }
    
    var body: some View {
        NavigationView {
            Form {
                //                Section(), content: {})
                ForEach(contractDevicesViewModel.devicesAsNodes) { device in
                    DeviceNodeView(deviceNode: device)
                }
            }
            .navigationTitle("ContractDevicesView.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        Task {
                            if await contractDevicesViewModel.save() {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }, label: {
                        if contractDevicesViewModel.showLoading {
                            ProgressView()
                        } else {
                            Text("ContractDevicesView.Save.Button")
                        }
                    })
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("ContractDevicesView.Cancel.Button") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct ContractDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        ContractDevicesView(contract: ContractPreviews.contractForPatientChatRowPreview)
    }
}
#endif
