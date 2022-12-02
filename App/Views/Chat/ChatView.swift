//
//  ChatView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All righchatViewModelts reserved.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject private var contract: Contract
    @ObservedObject private var user: User
    
    @EnvironmentObject private var contentViewModel: ContentViewModel
    
    @StateObject private var chatViewModel: ChatViewModel
    
    @FocusState private var isTextFocused
    
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
                VStack(spacing: 0) {
                    MessagesView(contract: contract)
                    Divider()
                    TextInputView()
                        .padding(.bottom, 3)
                }
                .deprecatedScrollDismissesKeyboard()
                .environmentObject(chatViewModel)
                
                NavigationLink(
                    destination: ContractView(contract: contract, user: user),
                    isActive: $showContractView
                ) {
                    EmptyView()
                }
                .isDetailLink(false)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    showContractView = true
                }, label: {
                    VStack {
                        Text(contract.wrappedShortName)
                            .foregroundColor(.primary)
                            .bold()
                        if userRole == .patient {
                            Text(contract.wrappedRole)
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
        .onAppear {
            contentViewModel.markChatAsOpened(contractId: Int(contract.id))
            chatViewModel.onChatViewAppear(contract: contract)
        }
//        .onDisappear {
//            contentViewModel.markChatAsClosed()
//        }
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
