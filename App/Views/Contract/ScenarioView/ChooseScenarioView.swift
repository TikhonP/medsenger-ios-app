//
//  ChooseScenarioView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChooseScenarioView: View {
    private static let allCategoryName = NSLocalizedString("ChooseScenarioView.allCategory", comment: "En: `All`, Ru: `Все`")
    
    @ObservedObject private var contract: Contract
    @ObservedObject private var clinic: Clinic
    
    @State private var categoryChoices = [allCategoryName]
    @State private var category: String = allCategoryName
    
    @Environment(\.presentationMode) private var presentationMode
    
    @FetchRequest private var scenarios: FetchedResults<ClinicScenario>
    
    @State private var searchText = ""
    var query: Binding<String> {
        Binding {
            searchText
        } set: { newValue in
            searchText = newValue
            if #available(iOS 15.0, *) {
                if newValue.isEmpty {
                    scenarios.nsPredicate = NSPredicate(format: "clinic == %@", clinic)
                } else {
                    scenarios.nsPredicate = NSPredicate(format: "(name CONTAINS[cd] %@ OR scenarioDescription CONTAINS[cd] %@) AND clinic == %@", newValue, newValue, clinic)
                }
            }
        }
    }
    
    init(contract: Contract, clinic: Clinic) {
        _scenarios = FetchRequest<ClinicScenario>(
            entity: ClinicScenario.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "clinic == %@", clinic),
            animation: .default
        )
        self.clinic = clinic
        self.contract = contract
    }
    
    var body: some View {
        NavigationView {
            List(scenarios) { scenario in
                NavigationLink(destination: {
                    ScenarioView(scenario: scenario, contractId: Int(contract.id))
                }, label: {
                    Label(scenario.wrappedName, systemImage: scenario.systemNameIcon)
                })
            }
            .searchableIos15Only(text: query)
            .navigationTitle("ChooseScenarioView.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("ChooseScenarioView.Filter.Picker", selection: $category, content: {
                            ForEach(categoryChoices, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        })
                    } label: {
                        Label("ChooseScenarioView.Filter.Label", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("ChooseScenarioView.Cancel.Button") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                Task(priority: .userInitiated) {
                    let categories = (try? await ClinicScenario.getScenariosCategories(clinic: clinic)) ?? [] + [ChooseScenarioView.allCategoryName]
                    await MainActor.run {
                        categoryChoices = categories
                    }
                }
            }
            .onChange(of: category, perform: { newCategory in
                if #available(iOS 15.0, *) {
                    updateCategoryFilter(newCategory)
                }
            })
        }
    }
    
    @available(iOS 15.0, *)
    func updateCategoryFilter(_ category: String) {
        if category == ChooseScenarioView.allCategoryName {
            if searchText.isEmpty {
                scenarios.nsPredicate = NSPredicate(format: "clinic == %@", clinic)
            } else {
                scenarios.nsPredicate = NSPredicate(format: "(name CONTAINS[cd] %@ OR scenarioDescription CONTAINS[cd] %@) AND clinic == %@", searchText, searchText, clinic)
            }
        } else {
            if searchText.isEmpty {
                scenarios.nsPredicate = NSPredicate(format: "clinic == %@ AND category == %@", clinic, category)
            } else {
                scenarios.nsPredicate = NSPredicate(format: "(name CONTAINS[cd] %@ OR scenarioDescription CONTAINS[cd] %@) AND clinic == %@ AND category == %@", searchText, searchText, clinic, category)
            }
        }
    }
}

#if DEBUG
struct ChooseScenarioView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseScenarioView(contract: ContractPreviews.contractForPatientChatRowPreview, clinic: ContractPreviews.contractForPatientChatRowPreview.clinic!)
    }
}
#endif
