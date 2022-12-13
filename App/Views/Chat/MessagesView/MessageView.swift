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
                
                // Reply:
                if let replyedMessage = message.replyToMessage {
                    ReplyPreviewView(replyedMessage: replyedMessage)
                    Divider()
                }
                
                // Voice message:
                if message.isVoiceMessage {
                    VoiceMessageView(message: message)
                }
                
                // Text:
                if !message.wrappedText.isEmpty && !message.isVoiceMessage {
                    TextMessageView(message: message)
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
            .readSize { size in
                if size.height < 49 {
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
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        MessageBodyView(message: message)
            .foregroundColor(.primary)
            .background(message.isMessageSent ? Color("SendedMessageBackgroundColor") : Color("RecievedMessageBackgroundColor"))
            .cornerRadius(20)
            .contextMenu {
                Button(action: {
                    chatViewModel.replyToMessage = message
                }, label: {
                    Label("Reply", systemImage: "arrowshape.turn.up.left")
                })
                if let text = message.text, !text.isEmpty {
                    Button(action: {
                        UIPasteboard.general.string = text
                    }, label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    })
                }
            }
            .frame(width: viewWidth * 0.7, alignment: message.isMessageSent ? .trailing : .leading)
            .frame(maxWidth: .infinity, alignment: message.isMessageSent ? .trailing : .leading)
            .id(Int(message.id))
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


struct BubbleShape: Shape {
    var myMessage : Bool
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        let bezierPath = UIBezierPath()
        if !myMessage {
            bezierPath.move(to: CGPoint(x: 20, y: height))
            bezierPath.addLine(to: CGPoint(x: width - 15, y: height))
            bezierPath.addCurve(to: CGPoint(x: width, y: height - 15), controlPoint1: CGPoint(x: width - 8, y: height), controlPoint2: CGPoint(x: width, y: height - 8))
            bezierPath.addLine(to: CGPoint(x: width, y: 15))
            bezierPath.addCurve(to: CGPoint(x: width - 15, y: 0), controlPoint1: CGPoint(x: width, y: 8), controlPoint2: CGPoint(x: width - 8, y: 0))
            bezierPath.addLine(to: CGPoint(x: 20, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 5, y: 15), controlPoint1: CGPoint(x: 12, y: 0), controlPoint2: CGPoint(x: 5, y: 8))
            bezierPath.addLine(to: CGPoint(x: 5, y: height - 10))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 5, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
            bezierPath.addLine(to: CGPoint(x: -1, y: height))
            bezierPath.addCurve(to: CGPoint(x: 12, y: height - 4), controlPoint1: CGPoint(x: 4, y: height + 1), controlPoint2: CGPoint(x: 8, y: height - 1))
            bezierPath.addCurve(to: CGPoint(x: 20, y: height), controlPoint1: CGPoint(x: 15, y: height), controlPoint2: CGPoint(x: 20, y: height))
        } else {
            bezierPath.move(to: CGPoint(x: width - 20, y: height))
            bezierPath.addLine(to: CGPoint(x: 15, y: height))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height - 15), controlPoint1: CGPoint(x: 8, y: height), controlPoint2: CGPoint(x: 0, y: height - 8))
            bezierPath.addLine(to: CGPoint(x: 0, y: 15))
            bezierPath.addCurve(to: CGPoint(x: 15, y: 0), controlPoint1: CGPoint(x: 0, y: 8), controlPoint2: CGPoint(x: 8, y: 0))
            bezierPath.addLine(to: CGPoint(x: width - 20, y: 0))
            bezierPath.addCurve(to: CGPoint(x: width - 5, y: 15), controlPoint1: CGPoint(x: width - 12, y: 0), controlPoint2: CGPoint(x: width - 5, y: 8))
            bezierPath.addLine(to: CGPoint(x: width - 5, y: height - 12))
            bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width - 5, y: height - 1), controlPoint2: CGPoint(x: width, y: height))
            bezierPath.addLine(to: CGPoint(x: width + 1, y: height))
            bezierPath.addCurve(to: CGPoint(x: width - 12, y: height - 4), controlPoint1: CGPoint(x: width - 4, y: height + 1), controlPoint2: CGPoint(x: width - 8, y: height - 1))
            bezierPath.addCurve(to: CGPoint(x: width - 20, y: height), controlPoint1: CGPoint(x: width - 15, y: height), controlPoint2: CGPoint(x: width - 20, y: height))
        }
        return Path(bezierPath.cgPath)
    }
}
#endif
