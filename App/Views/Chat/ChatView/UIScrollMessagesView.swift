//
//  UIScrollMessagesView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 15.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

struct UIScrollMessagesView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    @ObservedObject private var contract: Contract
    
    @FetchRequest private var messages: FetchedResults<Message>
    
    init(contract: Contract, inputViewHeight: Binding<CGFloat>) {
        self.contract = contract
        _messages = FetchRequest<Message>(
            entity: Message.entity(),
            sortDescriptors: [NSSortDescriptor(key: "sent", ascending: true)],
            predicate: NSPredicate(format: "contract == %@", contract),
            animation: .default
        )
    }
    
    var body: some View {
        GeometryReader { reader in
            UIScrollViewWrapper {
                VStack(spacing: 0) {
                    LazyVStack {
                        ForEach(messages) { message in
                            MessageView(viewWidth: reader.size.width, message: message)
                        }
                    }
                }
                .padding(.horizontal)
                
            }
        }
    }
}
