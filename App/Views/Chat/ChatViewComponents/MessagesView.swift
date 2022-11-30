//
//  MessagesView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 29.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import QuickLook

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct MessagesView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    @ObservedObject private var contract: Contract
    
    @FetchRequest private var messages: FetchedResults<Message>
    
    @State private var autoScrollDown = true
    @State private var showScrollDownButton = false
    
    init(contract: Contract) {
        self.contract = contract
        _messages = FetchRequest<Message>(
            entity: Message.entity(),
            sortDescriptors: [NSSortDescriptor(key: "sent", ascending: true)],
            predicate: NSPredicate(format: "contract == %@", contract),
            animation: .easeIn
        )
        
    }
    
    var body: some View {
        ZStack {
            GeometryReader { reader in
                ScrollView {
                    ScrollViewReader { scrollReader in
                        VStack(spacing: 0) {
                            LazyVStack {
                                ForEach(messages) { message in
                                    MessageView(message: message, viewWidth: reader.size.width)
                                }
                            }
                            Color.clear.id(-1)
                        }
                        .padding(.horizontal)
                        .quickLookPreview($chatViewModel.quickLookDocumentUrl)
                        .onAppear {
                            scrollTo(messageID: -1, shouldAnumate: false, scrollReader: scrollReader)
                        }
                        .onChange(of: contract.lastFetchedMessage, perform: { lastFetchedMessage in
                            if let lastFetchedMessage = lastFetchedMessage, autoScrollDown {
                                scrollTo(messageID: Int(lastFetchedMessage.id), shouldAnumate: true, scrollReader: scrollReader)
                            }
                        })
                        .environmentObject(chatViewModel)
                    }
                }
            }
        }
    }
    
    func scrollTo(messageID: Int, anchor: UnitPoint? = .bottom, shouldAnumate: Bool, scrollReader: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation(shouldAnumate ? Animation.easeIn : nil) {
                scrollReader.scrollTo(messageID, anchor: anchor)
            }
        }
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
        MessagesView(contract: contract1)
    }
}
