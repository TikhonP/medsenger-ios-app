//
//  AddContractView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct AddContractView: View {
    @StateObject private var addContractViewModel = AddContractViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    @FetchRequest(sortDescriptors: [], animation: .default) private var clinics: FetchedResults<Clinic>
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Institution"), footer: Text("Choose the clinic for patient")) {
                        Picker("Clinic", selection: $addContractViewModel.clinic, content: {
                            ForEach(clinics) { clinic in
                                Text(clinic.wrappedName).tag(clinic)
                            }
                        })
                    }
                    
                    Section(footer: Text("Email notes")) {
                        TextField("Patient Email", text: $addContractViewModel.patientEmail)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.emailAddress)
                    }
                    
                    if addContractViewModel.state == .inputClinicAndEmail {
                        Button("Find patient", action: addContractViewModel.findPatient)
                    } else if addContractViewModel.state == .fetchingUserFromMedsenger {
                        ProgressView()
                    }
                    
                    if addContractViewModel.state == .knownClient {
                        knownPatient
                    } else if addContractViewModel.state == .unknownClient {
                        patientDataForm
                        
                        contractDataForm
                    }
                    
                    if addContractViewModel.state != .fetchingUserFromMedsenger && addContractViewModel.state != .inputClinicAndEmail {
                        Button(action: {
                            addContractViewModel.addContract {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            if addContractViewModel.state == .submittingAddPatient {
                                ProgressView()
                            } else {
                                Text("Add Patient")
                            }
                        }
                    }
                }
            }
            .deprecatedScrollDismissesKeyboard()
            .navigationTitle("Add Patient")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    var patientDataForm: some View {
        Section(header: Text("Patient")) {
            TextField("Patient Name", text: $addContractViewModel.patientName)
                .textContentType(.name)
            Picker("Sex", selection: $addContractViewModel.patientSex) {
                Text("Make").tag(Sex.male)
                Text("Female").tag(Sex.female)
            }
            TextField("Phone", text: $addContractViewModel.patientPhone)
                .disableAutocorrection(true)
                .textContentType(.telephoneNumber)
                .keyboardType(.numberPad)
            DatePicker("Birthday", selection: $addContractViewModel.patientBirthday, displayedComponents: [.date])
        }
    }
    
    var contractDataForm: some View {
        Section(header: Text("Contract information")) {
            TextField("Contract Number", text: $addContractViewModel.contractNumber)
                .disableAutocorrection(true)
            DatePicker("Contract end date", selection: $addContractViewModel.contractEndDate)
            if let rules = addContractViewModel.clinic?.rulesArray {
                Picker("Answer time", selection: $addContractViewModel.clinicRule) {
                    ForEach(rules) { rule in
                        Text(rule.wrappedName).tag(rule)
                    }
                }
            }
            if let classifiers = addContractViewModel.clinic?.classifiersArray {
                Picker("Contract type", selection: $addContractViewModel.clinicClassifier) {
                    ForEach(classifiers) { classifier in
                        Text(classifier.wrappedName).tag(classifier)
                    }
                }
            }
            if let clinic = addContractViewModel.clinic, clinic.videoEnabled {
                Toggle("Video Calls", isOn: $addContractViewModel.videoEnabled)
            }
        }
    }
    
    var knownPatient: some View {
        Section(header: Text("Patient Found"), footer: Text("Make sure this is the person to whom you want to open the counseling channel. If not, correct the email and retry the request.")) {
            Text(addContractViewModel.patientName)
            Text("Birthday: \(addContractViewModel.patientBirthday)")
        }
    }
}

struct AddContractView_Previews: PreviewProvider {
    static var previews: some View {
        AddContractView()
    }
}
