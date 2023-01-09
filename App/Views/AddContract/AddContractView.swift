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
    @MainActor @Environment(\.presentationMode) private var presentationMode
    @FetchRequest(sortDescriptors: [], animation: .default) private var clinics: FetchedResults<Clinic>
    
    var body: some View {
        NavigationView {
            Form {
                intitutionSection
                emailFooterSection
                
                if addContractViewModel.state == .inputClinicAndEmail {
                    HStack {
                        Spacer()
                        Button("AddContractView.findPatient.Button", action: {
                            Task(priority: .userInitiated) {
                                await addContractViewModel.findPatient()
                            }
                        })
                        Spacer()
                    }
                } else if addContractViewModel.state == .fetchingUserFromMedsenger {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                
                if addContractViewModel.state == .knownClient {
                    knownPatient
                    contractDataForm
                } else if addContractViewModel.state == .unknownClient {
                    patientDataForm
                    contractDataForm
                }
                
                if addContractViewModel.state != .fetchingUserFromMedsenger && addContractViewModel.state != .inputClinicAndEmail {
                    Button {
                        Task(priority: .userInitiated) {
                            try await addContractViewModel.addContract()
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if addContractViewModel.submittingAddPatient {
                                ProgressView()
                            } else {
                                Text("AddContractView.addPatient.Button")
                            }
                            Spacer()
                        }
                    }
                }
            }
            .animation(.default, value: addContractViewModel.state)
            .scrollDismissesKeyboardIos16Only()
            .navigationTitle("AddContractView.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("AddContractView.cancel.Button") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(item: $addContractViewModel.alert) { $0.alert }
            .onChange(of: addContractViewModel.state, perform: { newState in
                if newState == .fetchingUserFromMedsenger {
                    hideKeyboard()
                }
            })
            .onChange(of: addContractViewModel.submittingAddPatient, perform: { newValue in
                if newValue {
                    hideKeyboard()
                }
            })
            .onAppear {
                print("Clinics: \(clinics)")
            }
        }
    }
    
    var emailFooterSection: some View {
        Section(footer: Text("AddContractView.email.Footer", comment: "It is necessary to provide an active email")) {
            TextField("AddContractView.patientEmail.TextField", text: $addContractViewModel.patientEmail)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .onChange(of: addContractViewModel.patientEmail, perform: { _ in
                    addContractViewModel.state = .inputClinicAndEmail
                })
        }
    }
    
    var intitutionSection: some View {
        Section(
            header: Text("AddContractView.institution.Header", comment: "Institution"),
            footer: Text("AddContractView.institution.Footer", comment: "Choose a clinic for the new patient")) {
                Picker("AddContractView.ClinicPicker", selection: $addContractViewModel.clinicId, content: {
                    ForEach(clinics) { clinic in
                        Text(clinic.wrappedName).tag(Int(clinic.id))
                    }
                })
            }
//            .onChange(of: addContractViewModel.clinicId, perform: { clinicId in
//
//            })
    }
    
    var patientDataForm: some View {
        Section(header: Text("AddContractView.patientData.Header", comment: "Patient")) {
            TextField("AddContractView.patientName.TextField", text: $addContractViewModel.patientName)
                .textContentType(.name)
            Picker("AddContractView.sex.Picker", selection: $addContractViewModel.patientSex) {
                ForEach(Sex.allCases, id: \.self) { sex in
                    Text(sex.rawValue).tag(sex)
                }
            }
            TextField("AddContractView.phone.TextField", text: $addContractViewModel.patientPhone)
                .disableAutocorrection(true)
                .textContentType(.telephoneNumber)
                .keyboardType(.numberPad)
            DatePicker("AddContractView.birthday.DatePicker", selection: $addContractViewModel.patientBirthday, displayedComponents: [.date])
        }
    }
    
    var contractDataForm: some View {
        Section(header: Text("AddContractView.contractData.Header", comment: "Contract information")) {
            TextField("AddContractView.contractNumber.TextField", text: $addContractViewModel.contractNumber)
                .disableAutocorrection(true)
            DatePicker("AddContractView.contractEndDate.DatePicker", selection: $addContractViewModel.contractEndDate, displayedComponents: [.date])
            if let rules = addContractViewModel.clinic?.rulesArray {
                Picker("AddContractView.responseTime.Picker", selection: $addContractViewModel.clinicRuleId) {
                    ForEach(rules) { rule in
                        Text(rule.wrappedName).tag(Int(rule.id))
                    }
                }
            }
            if let classifiers = addContractViewModel.clinic?.classifiersArray {
                Picker("AddContractView.contractType.Picker", selection: $addContractViewModel.clinicClassifierId) {
                    ForEach(classifiers) { classifier in
                        Text(classifier.wrappedName).tag(Int(classifier.id))
                    }
                }
            }
            if let clinic = addContractViewModel.clinic, clinic.videoEnabled {
                Toggle("AddContractView.videoCalls.Toggle", isOn: $addContractViewModel.videoEnabled)
            }
        }
    }
    
    var knownPatient: some View {
        Section(
            header: Text("AddContractView.knownPatient.Header", comment: "Patient Found"),
            footer: Text("AddContractView.knownPatient.Footer", comment: "Make sure this is the person you want to open the counseling channel for. If not, correct the email and resend the request.")) {
                Text(addContractViewModel.patientName)
                Text("AddContractView.birthday: \(addContractViewModel.patientBirthday, style: .date)")
            }
    }
}

#if DEBUG
struct AddContractView_Previews: PreviewProvider {
    static var previews: some View {
        AddContractView()
    }
}
#endif
