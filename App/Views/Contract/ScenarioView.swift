//
//  ScenarioView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ScenarioView: View {
    @ObservedObject var scenario: ClinicScenario
    
    @FetchRequest private var params: FetchedResults<ClinicScenarioParam>
    
    init(scenario: ClinicScenario) {
        _params = FetchRequest<ClinicScenarioParam>(
            entity: ClinicScenarioParam.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "scenario == %@", scenario),
            animation: .default
        )
        self.scenario = scenario
    }
    
    var body: some View {
        Form {
            ForEach(params) { param in
                Text(param.wrappedName)
            }
        }
        .navigationTitle(scenario.wrappedName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
//
//struct ScenarioView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScenarioView()
//    }
//}
