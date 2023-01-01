//
//  MessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessageBodyView: View {
    @ObservedObject private var message: Message
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme
    @FetchRequest private var imageAttachments: FetchedResults<ImageAttachment>
    
    @State private var addTrailingPadding = false
    
    init(message: Message) {
        self.message = message
        _imageAttachments = FetchRequest(
            entity: ImageAttachment.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "message == %@", message), animation: .default)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                if message.createSeparatorWithPreviousMessage {
                    MessageTitleView(message: message)
                } else if !(!imageAttachments.isEmpty && !hasNonImageContent) && !message.isVoiceMessage && message.replyToMessage == nil {
                    Color.clear
                        .frame(width: 0, height: 0)
                        .padding(.top, 10)
                }
                
                // Reply:
                if let replyedMessage = message.replyToMessage {
                    if !message.createSeparatorWithPreviousMessage {
                        Color.clear
                            .frame(width: 0, height: 0)
                            .padding(.top, 10)
                    }
                    ReplyPreviewView(replyedMessage: replyedMessage)
                }
                
                // Voice message:
                if message.isVoiceMessage {
                    VoiceMessageView(message: message)
                }
                
                // Text:
                if !message.wrappedText.isEmpty && !message.isVoiceMessage {
                    TextMessageView(message: message)
                }
                
                // Action link:
                if message.isAgent, message.actionLink != nil {
                    Button {
                        Task(priority: .userInitiated) {
                            await chatViewModel.openMessageActionLink(message: message)
                        }
                    } label: {
                        Label(message.wrappedActionName, systemImage: "bolt.fill")
                            .padding(10)
                            .background(Color("medsengerBlue"))
                            .cornerRadius(15)
                            .padding(10)
                    }
                }
                
                // Attachments
                if !message.isVoiceMessage {
                    if !message.attachmentsArray.isEmpty && hasNonAttachmentContent {
                        Divider()
                    }
                    ForEach(message.attachmentsArray) { attachment in
                        MessageAttachmentView(attachment: attachment)
                    }
                }
                
                // Images:
                if !imageAttachments.isEmpty && hasNonImageContent {
                    Divider()
                }
                
                ForEach(imageAttachments) { image in
                    MessageImageView(imageAttachment: image)
                }
            }
            .padding(.trailing, addTrailingPadding ? 30 : 0)
            .readMessageSize { size in
                if imageAttachments.isEmpty, size.height < 80, !message.isVoiceMessage {
                    addTrailingPadding = true
                }
            }
            MessageTimeBadge(message: message)
        }
    }
    
    var hasNonAttachmentContent: Bool {
        message.isVoiceMessage || !message.wrappedText.isEmpty
    }
    
    var hasNonImageContent: Bool {
        hasNonAttachmentContent || !message.attachmentsArray.isEmpty
    }
    
    var isNoAttachments: Bool {
        imageAttachments.isEmpty && message.attachmentsArray.isEmpty
    }
}

struct MessageView: View {
    let viewWidth: CGFloat
    @ObservedObject var message: Message
    @EnvironmentObject private var messageInputViewModel: MessageInputViewModel
    @Environment(\.colorScheme) private var colorScheme
    @GestureState private var isDragging = false
    @State private var dragGestureOffset: CGFloat = .zero
    @State private var isReplying = false
    @State private var feedbackGenerator: UISelectionFeedbackGenerator?
    
    private let swipeGestureConstant: CGFloat = 60

    var body: some View {
        if message.isVideoCallMessageFromDoctor {
            VideoCallMessageView(viewWidth: viewWidth, message: message)
                .id(Int(message.id))
        } else {
            ZStack(alignment: .trailing) {
                if isReplying {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .foregroundColor(.secondary)
                        .padding(.trailing)
                        .transition(.scale)
                }
                MessageBodyView(message: message)
                    .foregroundColor(foregroundColor)
                    .background(backgroundColor)
                    .cornerRadius(15)
                    .contextMenu {
                        Button(action: {
                            messageInputViewModel.replyToMessage = message
                        }, label: {
                            Label("MessageView.Reply.Button", systemImage: "arrowshape.turn.up.left")
                        })
                        if let text = message.text, !text.isEmpty {
                            Button(action: {
                                UIPasteboard.general.string = text
                            }, label: {
                                Label("MessageView.Copy.Button", systemImage: "doc.on.doc")
                            })
                        }
                    }
                    .frame(width: viewWidth * 0.7, alignment: message.isMessageSent ? .trailing : .leading)
                    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .frame(maxWidth: .infinity, alignment: message.isMessageSent ? .trailing : .leading)
                    .id(Int(message.id))
                    .offset(x: dragGestureOffset)
                    .gesture(
                        DragGesture()
                            .updating($isDragging, body: { _, out, _ in
                                out = true
                            })
                            .onChanged({ value in
                                if isDragging {
                                    let translation = value.translation.width
                                    if translation > 0 {
                                        // No swipe right
                                    } else if -translation < swipeGestureConstant {
                                        isReplying = false
                                        dragGestureOffset = translation
                                    } else {
                                        isReplying = true
                                        dragGestureOffset = -swipeGestureConstant + (translation + swipeGestureConstant) / 10
                                    }
                                }
                            })
                            .onEnded({ _ in
                                feedbackGenerator = nil
                                if isReplying {
                                    messageInputViewModel.replyToMessage = message
                                    isReplying = false
                                }
                                withAnimation {
                                    dragGestureOffset = 0
                                }
                            })
                    )
                    .onChange(of: isDragging, perform: { newValue in
                        if newValue {
                            feedbackGenerator = UISelectionFeedbackGenerator()
                            feedbackGenerator?.prepare()
                        }
                    })
                    .onChange(of: isReplying, perform: { _ in
                        if isDragging {
                            feedbackGenerator?.selectionChanged()
                            feedbackGenerator?.prepare()
                        }
                    })
                    .onAppear {
                        if !isDragging {
                            dragGestureOffset = 0
                        }
                    }
            }
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isReplying)
        }
    }
    
    var backgroundColor: Color {
        if message.isAgent, message.isUrgent {
            return Color("MessageDangerColor")
        } else if message.isAgent, message.isWarning {
            return Color("MessageWarningColor")
        } else if message.isMessageSent {
            return Color("SendedMessageBackgroundColor")
        } else {
            return Color("RecievedMessageBackgroundColor")
        }
    }
    
    var foregroundColor: Color {
        if message.isAgent, message.isUrgent {
            return .white
        } else if message.isAgent, message.isWarning {
            return .white
        } else if colorScheme == .light, !message.isMessageSent {
            return .white
        } else {
            return .primary
        }
    }
}

#if DEBUG
struct MessageView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var message1: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(for: context)
    }()
    
    static var message2: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(for: context, with: "sdsc dscsdcvs")
    }()
    
    static var previews: some View {
        Group {
            MessageView(viewWidth: 450, message: message1)
                .padding()
                .previewLayout(.sizeThatFits)
            
            MessageView(viewWidth: 450, message: message2)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
