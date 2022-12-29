//
//  MessagesView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 29.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import QuickLook

fileprivate struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    
    let content: () -> Content
    var body: some View {
        ZStack {
            content().background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: proxy.size
                    )
                }
            )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}

fileprivate struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

fileprivate struct ViewOffsetKey: PreferenceKey {
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
    
    @Binding private var inputViewHeight: CGFloat
    
    @State private var autoScrollDown = true
    @State private var showScrollDownButton = false
    @State private var scrollToBottom = false
    
    @State private var wholeSize: CGSize = .zero
    @State private var scrollViewSize: CGSize = .zero
    
    @State private var keyboardDidShowNotificationObserver: NSObjectProtocol?
    @State private var keyboardDidHideNotificationObserver: NSObjectProtocol?
    
    private let spaceName = "scroll"
    private let bottomScrollConstant: Double = 50
    
    private let scrollToBottomOffset: CGFloat = 60
    private let scrollViewBottomPadding: CGFloat = 45
    
    init(contract: Contract, inputViewHeight: Binding<CGFloat>) {
        self.contract = contract
        _inputViewHeight = inputViewHeight
        _messages = FetchRequest<Message>(
            entity: Message.entity(),
            sortDescriptors: __messagesSortDescriptors,
            predicate: NSPredicate(format: "contract == %@", contract),
            animation: .default
        )
        UIScrollView.appearance().decelerationRate = .fast
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing)  {
            scrollView
            ZStack {
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
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: showScrollDownButton)
        }
        .animation(.default, value: inputViewHeight)
        .alert(item: $chatViewModel.alert) { $0.alert }
        .sheet(isPresented: $chatViewModel.showActionWebViewModal) {
            if let agentActionUrl = chatViewModel.agentActionUrl, let agentActionName = chatViewModel.agentActionName {
                NavigationView {
                    WebView(url: agentActionUrl, title: agentActionName, showCloseButton: true) {
                        if let actionMessageId = chatViewModel.actionMessageId {
                            Task {
                                try? await Messages.messageActionUsed(messageId: actionMessageId)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var scrollView: some View {
        GeometryReader { reader in
            ChildSizeReader(size: $wholeSize) {
                ScrollView(showsIndicators: false) {
                    ScrollViewReader { scrollReader in
                        ChildSizeReader(size: $scrollViewSize) {
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
                                            MessageView(viewWidth: reader.size.width, message: message)
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
                                        value: -1 * proxy.frame(in: .named(spaceName)).origin.y
                                    )
                                }
                            )
                            .onPreferenceChange(
                                ViewOffsetKey.self,
                                perform: { value in
                                    if value >= (scrollViewSize.height - wholeSize.height) - bottomScrollConstant {
                                        showScrollDownButton = false
                                    } else {
                                        showScrollDownButton = true
                                    }
                                }
                            )
                            .quickLookPreview($chatViewModel.quickLookDocumentUrl)
                            .onAppear {
                                scrollTo(messageID: -1, animation: nil, scrollReader: scrollReader)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    scrollTo(messageID: -1, scrollReader: scrollReader)
                                }
                                
                                keyboardDidShowNotificationObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main, using: { _ in
                                    if !showScrollDownButton {
                                        scrollTo(messageID: -1, scrollReader: scrollReader)
                                    }
                                })
                                
                                keyboardDidHideNotificationObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main, using: { _ in
                                    if !showScrollDownButton {
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
                            .onChange(of: contract.lastFetchedMessage, perform: { lastFetchedMessage in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    scrollTo(messageID: -1, scrollReader: scrollReader)
                                }
                            })
                            .onChange(of: contract.lastGlobalFetchedMessage, perform: { lastFetchedMessage in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    if !showScrollDownButton {
                                        scrollTo(messageID: -1, animation: nil, scrollReader: scrollReader)
                                    }
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
                                if !showScrollDownButton {
                                    scrollTo(messageID: -1, scrollReader: scrollReader)
                                }
                            })
                        }
                    }
                }
                //                .fixFlickering()
                .coordinateSpace(name: spaceName)
            }
        }
    }
    
    func scrollTo(messageID: Int, anchor: UnitPoint? = .bottom, animation: Animation? = .easeIn, scrollReader: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation(animation) {
                scrollReader.scrollTo(messageID, anchor: anchor)
            }
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
