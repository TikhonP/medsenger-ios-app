//
//  ChatView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All righchatViewModelts reserved.
//

import SwiftUI

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}


struct ChatView: View {
    @ObservedObject private var contract: Contract
    @ObservedObject private var user: User
    
    @EnvironmentObject private var contentViewModel: ContentViewModel
    @EnvironmentObject private var networkConnectionMonitor: NetworkConnectionMonitor
    
    @StateObject private var chatViewModel: ChatViewModel
    @StateObject private var messageInputViewModel: MessageInputViewModel
    
    @AppStorage(UserDefaults.Keys.userRoleKey) private var userRole: UserRole = UserDefaults.userRole
    
    @FocusState private var isTextFocused
    
    @State private var inputViewHeight: CGFloat = 48.33
    @State private var openContractView = false
    
    init(contract: Contract, user: User) {
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(contractId: Int(contract.id)))
        _messageInputViewModel = StateObject(wrappedValue: MessageInputViewModel(contractId: Int(contract.id)))
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
            .onDrop(of: allDocumentsTypes, isTargeted: nil, perform: { providers in
                guard !providers.isEmpty else {
                    return false
                }
                for itemProvider in providers {
                    guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first else {
                        continue
                    }
                    itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        guard let url = url else {
                            return
                        }
                        do {
                            let data = try Data(contentsOf: url)
                            DispatchQueue.main.async {
                                messageInputViewModel.messageAttachments.append(ChatViewAttachment(
                                    data: data, extention: url.pathExtension, realFilename: url.lastPathComponent, type: .file))
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                return true
            })
            
            if contract.messagesArray.isEmpty {
                ProgressView()
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
                                        Text("online")
                                            .foregroundColor(.accentColor)
                                    } else {
                                        Text("offline")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } else {
                                Text("no connection")
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

#if DEBUG
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
#endif
