//
//  MessagesView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 29.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import QuickLook

struct ChildSizeReader<Content: View>: View {
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

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

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
    @State private var scrollToBottom = false
    
    @State private var wholeSize: CGSize = .zero
    @State private var scrollViewSize: CGSize = .zero
    
    let spaceName = "scroll"
    let bottomScrollConstant: Double = 50
    
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
            scrollView
            ZStack {
                if showScrollDownButton {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                scrollToBottom = true
                            }, label: {
                                ZStack {
                                    Circle()
                                        .foregroundColor(.gray)
                                        .scaledToFit()
                                        .frame(width: 40)
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                            })
                        }
                    }
                }
            }
            .transition(.slide)
        }
    }
    
    var scrollView: some View {
        GeometryReader { reader in
            ChildSizeReader(size: $wholeSize) {
                ScrollView {
                    ScrollViewReader { scrollReader in
                        ChildSizeReader(size: $scrollViewSize) {
                            VStack(spacing: 0) {
                                LazyVStack {
                                    ForEach(messages) { message in
                                        MessageView(message: message, viewWidth: reader.size.width)
                                    }
                                }
                                Color.clear.id(-1)
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
                                    withAnimation {
                                        if value >= (scrollViewSize.height - wholeSize.height) - bottomScrollConstant {
                                            showScrollDownButton = false
                                        } else {
                                            showScrollDownButton = true
                                        }
                                    }
                                }
                            )
                            .quickLookPreview($chatViewModel.quickLookDocumentUrl)
                            .onAppear {
                                scrollTo(messageID: -1, shouldAnumate: false, scrollReader: scrollReader)
                            }
                            .onChange(of: contract.lastFetchedMessage, perform: { lastFetchedMessage in
                                if let lastFetchedMessage = lastFetchedMessage, autoScrollDown {
                                    scrollTo(messageID: Int(lastFetchedMessage.id), shouldAnumate: true, scrollReader: scrollReader)
                                }
                            })
                            .onChange(of: chatViewModel.scrollToMessageId, perform: { scrollToMessageId in
                                if let scrollToMessageId = scrollToMessageId {
                                    scrollTo(messageID: Int(scrollToMessageId), anchor: .center, shouldAnumate: true, scrollReader: scrollReader)
                                    chatViewModel.scrollToMessageId = nil
                                }
                            })
                            .onChange(of: scrollToBottom, perform: { newValue in
                                if newValue {
                                    scrollTo(messageID: -1, shouldAnumate: true, scrollReader: scrollReader)
                                    scrollToBottom = false
                                }
                            })
                            .environmentObject(chatViewModel)
                            
                        }
                    }
                }
                .coordinateSpace(name: spaceName)
            }
        }
    }
    
    func scrollTo(messageID: Int, anchor: UnitPoint? = .bottomTrailing, shouldAnumate: Bool, scrollReader: ScrollViewProxy) {
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
