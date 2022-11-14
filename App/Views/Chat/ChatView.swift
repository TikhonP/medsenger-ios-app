//
//  ChatView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var chatViewModel: ChatViewModel
    
    @ObservedObject private var contract: Contract
    
    @FetchRequest private var messages: FetchedResults<Message>
    
    @FocusState private var isTextFocused
    
    @State private var autoScrollDown = true
    
    init(contract: Contract) {
        _messages = FetchRequest<Message>(
            entity: Message.entity(),
            sortDescriptors: [NSSortDescriptor(key: "sent", ascending: true)],
            predicate: NSPredicate(format: "contract == %@", contract),
            animation: .easeIn
        )
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(contractId: Int(contract.id)))
        self.contract = contract
    }
    
    var body: some View {
        VStack {
            GeometryReader { reader in
                ScrollView {
                    ScrollViewReader { scrollReader in
                        getMessagesView(viewWidth: reader.size.width)
                            .padding(.horizontal)
                            .onAppear {
                                if let messageID = messages.last?.id {
                                    scrollTo(messageID: Int(messageID), shouldAnumate: false, scrollReader: scrollReader)
                                }
                            }
                            .onChange(of: contract.lastFetchedMessageId, perform: { lastFetchedMessageId in
                                if autoScrollDown {
                                    scrollTo(messageID: Int(lastFetchedMessageId), shouldAnumate: true, scrollReader: scrollReader)
                                }
                            })
                    }
                }
            }
            
            if #available(iOS 15.0, *) {
                textInput
            }
        }
        .padding(.top, 1)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: navigationVarLeading(contract: contract), trailing: navigationVarTrailing)
        .onAppear(perform: chatViewModel.fetchMessages)
    }
    
    func navigationVarLeading(contract: Contract) -> some View {
        Button(action: {}) {
            HStack {
                if let image = contract.avatar {
                    Image(data: image)?
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    
                    Text(contract.shortName ?? "Unknown name")
                        .bold()
                }
            }
        }
    }
    
    var navigationVarTrailing: some View {
        Button(action: {
            if let messageId = messages.last?.id {
                chatViewModel.messageIDToScroll = Int(messageId)
            }
        }) {
            Text("Lol")
        }
    }
    
    @available(iOS 15.0, *)
    var textInput: some View {
        VStack {
            let height: CGFloat = 37
            HStack {
                TextField("Message...", text: $chatViewModel.message)
                    .padding(.horizontal, 10)
                    .frame(height: height)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .focused($isTextFocused)
                
                Button(action: chatViewModel.sendMessage) {
                    Image(systemName: "arrow.up.circle")
                        .foregroundColor(.white)
                        .frame(width: height, height: height)
                }
            }
            .frame(height: height)
        }
        .padding(.vertical)
        .padding(.horizontal)
        .background(Color.gray)
    }
    
    func scrollTo(messageID: Int, anchor: UnitPoint? = nil, shouldAnumate: Bool, scrollReader: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation(shouldAnumate ? Animation.easeIn : nil) {
                scrollReader.scrollTo(messageID, anchor: anchor)
            }
        }
    }
    
    func getMessagesView(viewWidth: CGFloat) -> some View {
        VStack {
            LazyVStack {
                ForEach(messages.dropLast(10)) { message in
                    messageView(message: message, viewWidth: viewWidth)
                }
            }
            
            VStack {
                ForEach(messages.suffix(10)) { message in
                    messageView(message: message, viewWidth: viewWidth)
                }
            }
        }
    }
    
    func messageView(message: Message, viewWidth: CGFloat) -> some View {
        HStack {
            ZStack {
                Text(message.text ?? "Unknown text")
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(message.isMessageSent ? Color.green.opacity(0.9) : .black.opacity(0.2))
                    .cornerRadius(13)
            }
            .frame(width: viewWidth * 0.7, alignment: message.isMessageSent ? .trailing : .leading)
            .padding(.vertical)
        }
        .frame(maxWidth: .infinity, alignment: message.isMessageSent ? .trailing : .leading)
        .id(Int(message.id))
    }
}

struct ChatView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var previews: some View {
        ChatView(contract: contract1)
    }
}
