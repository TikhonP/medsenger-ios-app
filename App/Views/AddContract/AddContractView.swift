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
                        Picker("Clinic", selection: $addContractViewModel.clinicId, content: {
                            ForEach(clinics) { clinic in
                                Text(clinic.wrappedName).tag(Int(clinic.id))
                            }
                        })
                    }
                    .onChange(of: addContractViewModel.clinicId, perform: { clinicId in
                        addContractViewModel.state = .inputClinicAndEmail
                        addContractViewModel.clinic = Clinic.get(id: clinicId)
                    })
                    
                    Section(footer: Text("Email notes")) {
                        TextField("Patient Email", text: $addContractViewModel.patientEmail)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.emailAddress)
                            .onChange(of: addContractViewModel.patientEmail, perform: { _ in
                                addContractViewModel.state = .inputClinicAndEmail
                            })
                    }
                    
                    
                    if addContractViewModel.state == .inputClinicAndEmail {
                        HStack {
                            Spacer()
                            Button("Find patient", action: addContractViewModel.findPatient)
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
                        Button(action: {
                            addContractViewModel.addContract {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            HStack {
                                Spacer()
                                if addContractViewModel.submittingAddPatient {
                                    ProgressView()
                                } else {
                                    Text("Add Patient")
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .deprecatedScrollDismissesKeyboard()
            .navigationTitle("Add Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $addContractViewModel.showContractExistsAlert) {
                Alert(
                    title: Text("Contract already exists"),
                    message: Text("Please check email. Contract with provided email already exists")
                )
            }
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
        }
    }
    
    var patientDataForm: some View {
        Section(header: Text("Patient")) {
            TextField("Patient Name", text: $addContractViewModel.patientName)
                .textContentType(.name)
            Picker("Sex", selection: $addContractViewModel.patientSex) {
                ForEach(Sex.allCases, id: \.self) { sex in
                    Text(sex.rawValue).tag(sex)
                }
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
            DatePicker("Contract end date", selection: $addContractViewModel.contractEndDate, displayedComponents: [.date])
            if let rules = addContractViewModel.clinic?.rulesArray {
                Picker("Answer time", selection: $addContractViewModel.clinicRuleId) {
                    ForEach(rules) { rule in
                        Text(rule.wrappedName).tag(Int(rule.id))
                    }
                }
            }
            if let classifiers = addContractViewModel.clinic?.classifiersArray {
                Picker("Contract type", selection: $addContractViewModel.clinicClassifierId) {
                    ForEach(classifiers) { classifier in
                        Text(classifier.wrappedName).tag(Int(classifier.id))
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
            Text("Birthday: \(addContractViewModel.patientBirthday, formatter: DateFormatter.ddMMyyyy)")
        }
    }
}

struct AddContractView_Previews: PreviewProvider {
    static var previews: some View {
        AddContractView()
    }
}
