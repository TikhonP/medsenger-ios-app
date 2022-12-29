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
    @EnvironmentObject private var networkConnectionMonitor: NetworkConnectionMonitor
    
    @StateObject private var chatViewModel: ChatViewModel
    @StateObject private var messageInputViewModel: MessageInputViewModel
    
    @AppStorage(UserDefaults.Keys.userRoleKey) private var userRole: UserRole = UserDefaults.userRole
    
    @State private var inputViewHeight: CGFloat = 48.33
    @State private var openContractView = false
    
    init(contract: Contract, user: User) {
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(contractId: Int(contract.id)))
        _messageInputViewModel = StateObject(
            wrappedValue: MessageInputViewModel(
                contractId: Int(contract.id),
                messageDraft: contract.wrappedMessageDraft))
        self.contract = contract
        self.user = user
    }
    
    var body: some View {
        ZStack {
            NavigationLink(isActive: $openContractView, destination: {
                ContractView(contract: contract, user: user)
            }, label: {
                EmptyView()
            })
            .isDetailLink(false)
            
            ZStack(alignment: .bottom) {
                MessagesView(contract: contract, inputViewHeight: $inputViewHeight)
                MessageInputView()
                    .readSize { size in
                        inputViewHeight = size.height
                    }
            }
            .scrollDismissesKeyboardIos16Only()
            .environmentObject(chatViewModel)
            .environmentObject(messageInputViewModel)
            .onDrop(of: allDocumentsTypes, isTargeted: nil, perform: messageInputViewModel.addOnDropAttachments)
            
            if contract.messagesArray.isEmpty {
                VStack(alignment: .center) {
                    ProgressView()
                    Text("ChatView.loadingText", comment: "The first time you open a chat, all messages are loaded, this may take some time.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    openContractView = true
                }, label: {
                    VStack {
                        Text(contract.wrappedShortName)
                            .foregroundColor(.primary)
                            .bold()
                        ZStack {
                            if networkConnectionMonitor.isConnected {
                                if userRole == .patient {
                                    Text(contract.wrappedRole)
                                        .foregroundColor(.accentColor)
                                } else if userRole == .doctor {
                                    if contract.isOnline {
                                        Text("ChatView.online", comment: "online")
                                            .foregroundColor(.accentColor)
                                    } else {
                                        Text("ChatView.offline", comment: "offline")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } else {
                                Text("ChatView.noConnection", comment: "no connection")
                                    .foregroundColor(.pink)
                            }
                        }
                        .font(.caption)
                        .animation(.default, value: networkConnectionMonitor.isConnected)
                        .animation(.default, value: contract.isOnline)
                    }
                })
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    openContractView = true
                }, label: {
                    userAvatar
                })
            }
        }
        .onAppear {
            contentViewModel.markChatAsOpened(contractId: Int(contract.id))
            Task {
                await chatViewModel.onChatViewAppear(contract: contract)
            }
        }
        .onDisappear {
            contentViewModel.markChatAsClosed()
        }
    }
    
    var userAvatar: some View {
        ZStack {
            if contract.isConsilium {
                if let patientAvatar = contract.patientAvatar, let doctorAvatar = contract.doctorAvatar {
                    Image(data: patientAvatar)?
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 40)
                        .overlay(Circle().stroke(Color.systemBackground, lineWidth: 2))
                        .offset(x: -20)
                    Image(data: doctorAvatar)?
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 40)
                        .overlay(Circle().stroke(Color.systemBackground, lineWidth: 2))
                }
            } else {
                if let image = contract.avatar {
                    Image(data: image)?
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 40)
                }
            }
        }
    }
}

#if DEBUG
//struct ChatView_Previews: PreviewProvider {
//    static let persistence = PersistenceController.preview
//    
//    static var contract1: Contract = {
//        let context = persistence.container.viewContext
//        let contract = Contract.createSampleContract1(for: context)
//        PersistenceController.save(for: context)
//        return contract
//    }()
//    
//    static var user: User = {
//        let context = persistence.container.viewContext
//        let user = User.createSampleUser(for: context)
//        PersistenceController.save(for: context)
//        return user
//    }()
//    
//    static var previews: some View {
//        NavigationView {
//            ChatView(contract: contract1, user: user)
//                .environment(\.managedObjectContext, persistence.container.viewContext)
//        }
//    }
//}
#endif
