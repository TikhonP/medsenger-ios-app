//
//  EditNotesView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

final class EditNotesViewModel: ObservableObject {
    @Published var note: String
    @Published var showLoading = false
    
    private let contractId: Int
    
    init(contract: Contract) {
        self.note = contract.wrappedComments
        self.contractId = Int(contract.id)
    }
    
    func save(completion: @escaping () -> Void) {
        showLoading = true
        DoctorActions.shared.updateContractNotes(contractId: contractId, notes: note) { [weak self] succeeded in
            DispatchQueue.main.async {
                self?.showLoading = false
                if succeeded {
                    completion()
                }
            }
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
                .navigationTitle("Edit Notes")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            editNotesViewModel.save {
                                presentationMode.wrappedValue.dismiss()
                            }}, label: {
                                if editNotesViewModel.showLoading {
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

//struct EditNotesView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditNotesView()
//    }
//}
