//
//  EditNotesView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

@MainActor
final class EditNotesViewModel: ObservableObject, Alertable {
    @Published var alert: AlertInfo?
    
    @Published var note: String
    @Published var showLoading = false
    
    private let contractId: Int
    
    init(contract: Contract) {
        self.note = contract.wrappedComments
        self.contractId = Int(contract.id)
    }
    
    func save() async -> Bool {
        showLoading = true
        do {
            try await DoctorActions.updateContractNotes(contractId: contractId, notes: note)
            showLoading = false
            return true
        } catch {
            showLoading = false
            presentGlobalAlert()
            return false
        }
    }
}

struct EditNotesView: View {
    @StateObject private var editNotesViewModel: EditNotesViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(contract: Contract) {
        _editNotesViewModel = StateObject(wrappedValue: EditNotesViewModel(contract: contract))
    }
    
    var body: some View {
        NavigationView {
            TextEditor(text: $editNotesViewModel.note)
                .padding(.horizontal)
                .navigationTitle("EditNotesViewModel.NavigationTitle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            Task {
                                if await editNotesViewModel.save() {
                                    await MainActor.run {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }, label: {
                            if editNotesViewModel.showLoading {
                                ProgressView()
                            } else {
                                Text("EditNotesViewModel.Save.Button")
                            }
                        })
                    }
                    
                    ToolbarItem(placement: .cancellationAction) {
                        Button("EditNotesViewModel.Cancel.Button") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .alert(item: $editNotesViewModel.alert) { $0.alert }
        }
    }
}

//struct EditNotesView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditNotesView()
//    }
//}
