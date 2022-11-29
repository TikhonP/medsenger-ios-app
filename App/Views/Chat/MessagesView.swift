//
//  MessagesView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 29.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessagesView: View {
    let viewWidth: CGFloat
    
    @ObservedObject private var contract: Contract
    
    @FetchRequest private var messages: FetchedResults<Message>
    
    init(contract: Contract, viewWidth: CGFloat) {
        self.viewWidth = viewWidth
        self.contract = contract
        _messages = FetchRequest<Message>(
            entity: Message.entity(),
            sortDescriptors: [NSSortDescriptor(key: "sent", ascending: true)],
            predicate: NSPredicate(format: "contract == %@", contract),
            animation: .easeIn
        )
        
    }
    
    var body: some View {
        VStack {
            LazyVStack {
                ForEach(messages.dropLast(10)) { message in
                    MessageView(message: message, viewWidth: viewWidth)
                }
            }
            
            VStack {
                ForEach(messages.suffix(10)) { message in
                    MessageView(message: message, viewWidth: viewWidth)
                }
            }
        }
        .padding(.horizontal, 5)
    }
}

struct MessagesView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        let contract = Contract.createSampleContract1(for: context)
        PersistenceController.save(for: context)
        return contract
    }()
    
    static var previews: some View {
        GeometryReader { reader in
            MessagesView(contract: contract1, viewWidth: reader.size.width)
        }
    }
}
