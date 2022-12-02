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
    
    let id = UUID()
    let medsengerId: Int
    let name: String
    let description: String
    
    init(_ device: ClinicDevice) {
        self.name = device.wrappedName
        self.description = device.wrappedDescription
        self.medsengerId = Int(device.id)
        self.isEnabled = false
    }
}

final class ContractDevicesViewModel: ObservableObject {
    @Published var devicesAsNodes = [DeviceNode]()
    
    let contract: Contract
    
    init(contract: Contract) {
        self.contract = contract
        
        guard let clinic = contract.clinic else {
            return
        }
        for device in clinic.devicesArray {
            devicesAsNodes.append(DeviceNode(device))
        }
    }
    
    func save(completion: @escaping () -> Void) {
        DoctorActions.shared.deviceState(devices: devicesAsNodes, contractId: Int(contract.id)) { succeeded in
            if succeeded {
                DispatchQueue.main.async {
                    completion()
                }
            }
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
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var contractDevicesViewModel: ContractDevicesViewModel
    
    @State private var showLoading = false
    
    init(contract: Contract) {
        self.contract = contract
        _contractDevicesViewModel = StateObject(wrappedValue: ContractDevicesViewModel(contract: contract))
    }
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(contractDevicesViewModel.devicesAsNodes) { device in
                    DeviceNodeView(deviceNode: device)
                }
            }
            .navigationTitle("Devices Control")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        showLoading = true
                        contractDevicesViewModel.save {
                            showLoading = false
                            presentationMode.wrappedValue.dismiss()
                        }}, label: {
                            if showLoading {
                                ProgressView()
                            } else {
                                Text("Save")
                            }
                        })
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ContractDevicesView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var previews: some View {
        ContractDevicesView(contract: contract1)
    }
}
