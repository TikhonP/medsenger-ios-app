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
    @ObservedObject private var user: User
    
    @FocusState private var isTextFocused
    
    @State private var autoScrollDown = true
    @State private var showContractView = false
    
    @AppStorage(UserDefaults.Keys.userRoleKey)
    private var userRole: UserRole = UserDefaults.userRole
    
    init(contract: Contract, user: User) {
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(contractId: Int(contract.id)))
        self.contract = contract
        self.user = user
    }
    
    var body: some View {
        VStack {
            if contract.messagesArray.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ZStack {
                    GeometryReader { reader in
                        ScrollView {
                            ScrollViewReader { scrollReader in
                                MessagesView(contract: contract, viewWidth: reader.size.width)
                                    .onAppear {
                                        if let messageID = contract.messagesArray.last?.id {
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
}

struct ChatView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        let contract = Contract.createSampleContract1(for: context)
        PersistenceController.save(for: context)
        return contract
    }()
    
    static var user: User = {
        let context = persistence.container.viewContext
        let user = User.createSampleUser(for: context)
        PersistenceController.save(for: context)
        return user
    }()
    
    static var previews: some View {
        NavigationView {
            ChatView(contract: contract1, user: user)
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
