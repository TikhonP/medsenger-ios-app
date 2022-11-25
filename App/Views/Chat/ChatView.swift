//
//  ChatView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All righchatViewModelts reserved.
//

import SwiftUI
import QuickLook

struct ChatView: View {
    @StateObject private var chatViewModel: ChatViewModel
    
    @ObservedObject private var contract: Contract
    @ObservedObject var user: User
    
    @FetchRequest private var messages: FetchedResults<Message>
    
    @FocusState private var isTextFocused
    
    @State private var autoScrollDown = true
    @State var showContractView = false
    
    @AppStorage(UserDefaults.Keys.userRoleKey) var userRole: UserRole = UserDefaults.userRole
    
    init(contract: Contract, user: User) {
        _messages = FetchRequest<Message>(
            entity: Message.entity(),
            sortDescriptors: [NSSortDescriptor(key: "sent", ascending: true)],
            predicate: NSPredicate(format: "contract == %@", contract),
            animation: .easeIn
        )
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(contractId: Int(contract.id)))
        self.contract = contract
        self.user = user
    }
    
    var body: some View {
        VStack {
            if messages.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ZStack {
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
                                    .onChange(of: contract.lastFetchedMessage, perform: { lastFetchedMessage in
                                        if let lastFetchedMessage = lastFetchedMessage, autoScrollDown {
                                            scrollTo(messageID: Int(lastFetchedMessage.id), shouldAnumate: true, scrollReader: scrollReader)
                                        }
                                    })
                                    .padding(.bottom, 55)
                                    .environmentObject(chatViewModel)
                            }
                        }
                    }
                    
                    VStack {
                        Spacer()
                        TextInputView()
                            .environmentObject(chatViewModel)
                    }
                }
                .quickLookPreview($chatViewModel.quickLookDocumentUrl)
                
                NavigationLink(
                    destination: ContractView(contract: contract, user: user),
                    isActive: $showContractView
                ) {
                    EmptyView()
                }
                .isDetailLink(false)
            }
        }
        .padding(.top, 1)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: chatViewModel.fetchMessages)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    showContractView = true
                }, label: {
                    VStack {
                        Text(contract.shortName ?? "Unknown name")
                            .foregroundColor(.primary)
                            .bold()
                        if userRole == .patient {
                            Text(contract.role ?? "Unknown role")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                })
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showContractView = true
                }, label: {
                    if let image = contract.avatar {
                        Image(data: image)?
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                })
            }
        }
    }
    
    func scrollTo(messageID: Int, anchor: UnitPoint? = .top, shouldAnumate: Bool, scrollReader: ScrollViewProxy) {
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
                    MessageView(message: message, viewWidth: viewWidth)
                }
            }
            
            VStack {
                ForEach(messages.suffix(10)) { message in
                    MessageView(message: message, viewWidth: viewWidth)
                }
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var user: User = {
        let context = persistence.container.viewContext
        return User.createSampleUser(for: context)
    }()
    
    static var previews: some View {
        NavigationView {
            ChatView(contract: contract1, user: user)
        }
    }
}
