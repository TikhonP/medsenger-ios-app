//
//  MessagesView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 29.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import QuickLook

fileprivate struct ViewOffsetScrollData: Equatable {
    let viewOffset: CGFloat
    let scrollViewHeight: CGFloat
    
    static var zero = {
        ViewOffsetScrollData(viewOffset: .zero, scrollViewHeight: .zero)
    }()
}

fileprivate struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: ViewOffsetScrollData = .zero
    static func reduce(value: inout ViewOffsetScrollData, nextValue: () -> Value) {}
}

struct MessagesView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    @ObservedObject private var contract: Contract
    
    @FetchRequest private var messages: FetchedResults<Message>
    
    @Binding private var inputViewHeight: CGFloat
    
    @State private var showScrollDownButton = false
    @State private var allowScrollToBottom = true
    @State private var scrollToBottom = false
    
    @State private var keyboardDidShowNotificationObserver: NSObjectProtocol?
    @State private var keyboardDidHideNotificationObserver: NSObjectProtocol?
    
    private let spaceName = "scroll"
    private let bottomScrollConstant: Double = 50
    private let doNotScrollToBottomConstant: Double = 150
    
    private let scrollToBottomOffset: CGFloat = 60
    private let scrollViewBottomPadding: CGFloat = 45
    
    init(contract: Contract, inputViewHeight: Binding<CGFloat>) {
        self.contract = contract
        _inputViewHeight = inputViewHeight
        _messages = FetchRequest<Message>(
            entity: Message.entity(),
            sortDescriptors: __messagesSortDescriptors,
            predicate: NSPredicate(format: "contract == %@", contract),
            animation: .easeIn
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing)  {
            scrollView
            Group {
                if showScrollDownButton {
                    Button(action: {
                        scrollToBottom = true
                    }, label: {
                        ScrollToBottomLabelView()
                            .padding(.trailing, 5)
                    })
                    .transition(.scale)
                    .padding(.bottom, inputViewHeight + 15)
                }
            }
        }
        .animation(.default, value: inputViewHeight)
        .alert(item: $chatViewModel.alert) { $0.alert }
        .sheet(isPresented: $chatViewModel.showActionWebViewModal) {
            if let agentActionUrl = chatViewModel.agentActionUrl, let agentActionName = chatViewModel.agentActionName {
                NavigationView {
                    WebView(url: agentActionUrl, title: agentActionName, showCloseButton: true) {
                        if let actionMessageId = chatViewModel.actionMessageId {
                            Task(priority: .background) {
                                try? await Messages.messageActionUsed(messageId: actionMessageId)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var scrollView: some View {
        GeometryReader { wholeViewProxy in
            ScrollView(showsIndicators: false) {
                ScrollViewReader { scrollReader in
                    VStack(spacing: 0) {
                        LazyVStack(spacing: 0) {
                            ForEach(messages) { message in
                                if message.showMessage {
                                    if let messageSent = message.sent {
                                        if let previousMessageSent = message.previousMessage?.sent {
                                            if !previousMessageSent.isInSameDay(as: messageSent) {
                                                MessageTimeDividerView(date: messageSent)
                                                    .padding(.top, 7)
                                            }
                                        } else {
                                            MessageTimeDividerView(date: messageSent)
                                                .padding(.top, 7)
                                        }
                                    }
                                    MessageView(viewWidth: wholeViewProxy.size.width, message: message)
                                        .padding(.top, message.createSeparatorWithPreviousMessage ? 7 : 3)
                                }
                            }
                        }
                        
                        Color.clear.id(-1)
                            .padding(.bottom, inputViewHeight)
                    }
                    .padding(.horizontal)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ViewOffsetKey.self,
                                value: ViewOffsetScrollData(
                                    viewOffset: -1 * proxy.frame(in: .named(spaceName)).origin.y,
                                    scrollViewHeight: proxy.size.height
                                )
                            )
                        }
                    )
                    .onAppear {
                        scrollTo(messageID: -1, animation: nil, scrollReader: scrollReader)
                        
                        Task(priority: .high) {
                            let isFirstFetch = try await chatViewModel.fetchMessages()
                            if isFirstFetch || allowScrollToBottom {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    scrollTo(messageID: -1, scrollReader: scrollReader)
                                }
                            }
                        }
                        
                        keyboardDidShowNotificationObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main, using: { _ in
                            if allowScrollToBottom {
                                scrollTo(messageID: -1, scrollReader: scrollReader)
                            }
                        })
                        
                        keyboardDidHideNotificationObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main, using: { _ in
                            if allowScrollToBottom {
                                scrollTo(messageID: -1, scrollReader: scrollReader)
                            }
                        })
                    }
                    .onDisappear {
                        if let keyboardDidShowNotificationObserver = keyboardDidShowNotificationObserver {
                            NotificationCenter.default.removeObserver(keyboardDidShowNotificationObserver)
                        }
                        if let keyboardDidHideNotificationObserver = keyboardDidHideNotificationObserver {
                            NotificationCenter.default.removeObserver(keyboardDidHideNotificationObserver)
                        }
                    }
                    .onChange(of: messages.count, perform: { _ in
                        if allowScrollToBottom {
                            scrollTo(messageID: -1, scrollReader: scrollReader)
                        }
                    })
                    .onChange(of: chatViewModel.scrollToMessageId, perform: { scrollToMessageId in
                        if let scrollToMessageId = scrollToMessageId {
                            scrollTo(messageID: Int(scrollToMessageId), anchor: .center, scrollReader: scrollReader)
                            chatViewModel.scrollToMessageId = nil
                        }
                    })
                    .onChange(of: scrollToBottom, perform: { newValue in
                        if newValue {
                            scrollTo(messageID: -1, scrollReader: scrollReader)
                            scrollToBottom = false
                        }
                    })
                    .onChange(of: inputViewHeight, perform: { _ in
                        if allowScrollToBottom {
                            scrollTo(messageID: -1, scrollReader: scrollReader)
                        }
                    })
                }
            }
            .coordinateSpace(name: spaceName)
            .onPreferenceChange(
                ViewOffsetKey.self,
                perform: { value in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        if value.viewOffset >= (value.scrollViewHeight - wholeViewProxy.size.height) - bottomScrollConstant {
                            showScrollDownButton = false
                        } else {
                            showScrollDownButton = true
                        }
                    }
                    if value.viewOffset >= (value.scrollViewHeight - wholeViewProxy.size.height) - doNotScrollToBottomConstant {
                        allowScrollToBottom = true
                    } else {
                        allowScrollToBottom = false
                    }
                }
            )
        }
    }
    
    @MainActor func scrollTo(messageID: Int, anchor: UnitPoint? = .bottom, animation: Animation? = .easeIn, scrollReader: ScrollViewProxy) {
        withAnimation(animation) {
            scrollReader.scrollTo(messageID, anchor: anchor)
        }
    }
}

#if DEBUG
struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(contract: ContractPreviews.contractForPatientChatRowPreview, inputViewHeight: .constant(0))
    }
}
#endif
