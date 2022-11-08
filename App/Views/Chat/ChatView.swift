//
//  ChatView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChatView: View {
    let contract: Contract
    
    @StateObject var chatViewModel = ChatViewModel()
    
    @FetchRequest private var messages: FetchedResults<Message>
    
    @FocusState private var isTextFocused
    
    @State private var messageIDToScroll: Int?
    
    init(contract: Contract) {
        _messages = FetchRequest<Message>(
            entity: Message.entity(),
            sortDescriptors: [NSSortDescriptor(key: "sent", ascending: true)],
            predicate: NSPredicate(format: "contract == %@", contract),
            animation: .easeIn
        )
        self.contract = contract
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { reader in
                ScrollView {
                    ScrollViewReader { scrollReader in
                        getMessagesView(viewWidth: reader.size.width)
                            .padding(.horizontal)
                            .onChange(of: messageIDToScroll) { newValue in
                                if let messageID = newValue {
                                    scrollTo(messageID: messageID, shouldAnumate: true, scrollReader: scrollReader)
                                }
                            }
                            .onAppear {
                                if let messageID = messages.last?.id {
                                    scrollTo(messageID: Int(messageID), anchor: .bottom, shouldAnumate: false, scrollReader: scrollReader)
                                }
                            }
                    }
                }
            }
            
            if #available(iOS 15.0, *) {
                textInput
            }
        }
        .padding(.top, 1)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: navigationVarLeading, trailing: navigationVarTrailing)
        .onAppear(perform: { chatViewModel.fetchMessages(contractId: Int(contract.id)) })
    }
    
    let columns = [GridItem(.flexible(minimum: 10))]
    
    var navigationVarLeading: some View {
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
        Button(action: {}) {
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
                
                Button(action: {}) {
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
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(messages) { message in
                HStack {
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
                    .id(message.id)
                }
            }
        }
    }
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView(contractId: 1234)
//    }
//}
