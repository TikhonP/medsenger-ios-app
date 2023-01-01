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
    
    func save() async throws {
        showLoading = true
        do {
            try await DoctorActions.updateContractNotes(contractId: contractId, notes: note)
            showLoading = false
        } catch {
            showLoading = false
            presentGlobalAlert()
            throw error
        }
    }
}

struct EditNotesView: View {
    @StateObject private var editNotesViewModel: EditNotesViewModel
    @MainActor @Environment(\.presentationMode) private var presentationMode
    
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
                        Button {
                            Task(priority: .userInitiated) {
                                try await editNotesViewModel.save()
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            if editNotesViewModel.showLoading {
                                ProgressView()
                            } else {
                                Text("EditNotesViewModel.Save.Button")
                            }
                        }
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
