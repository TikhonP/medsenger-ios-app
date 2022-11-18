//
//  InfoMaterialsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct InfoMaterialsView: View {
    @ObservedObject var contract: Contract
    
    @FetchRequest private var infoMaterials: FetchedResults<InfoMaterial>
    
    init(contract: Contract) {
        _infoMaterials = FetchRequest<InfoMaterial>(
            entity: InfoMaterial.entity(),
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
            predicate: NSPredicate(format: "contract == %@", contract),
            animation: .easeIn
        )
        self.contract = contract
    }
    
    var body: some View {
        ZStack {
            if infoMaterials.isEmpty {
                Text("There is no info materials")
            } else {
                List(infoMaterials) { infoMaterial in
                    if let name = infoMaterial.name, let link = infoMaterial.link {
                        Link(name, destination: link)
                    }
                }
            }
        }
        .navigationTitle("Info materials")
    }
}

struct InfoMaterialsView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var previews: some View {
        InfoMaterialsView(contract: contract1)
    }
}
