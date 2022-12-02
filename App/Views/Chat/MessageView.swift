//
//  MessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessageView: View {
    @ObservedObject var message: Message
    let viewWidth: CGFloat
    
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        HStack {
            ZStack {
                if message.isMessageSent {
                    messageBody
                        .padding(9)
                        .background(Color.secondary.opacity(0.5))
                        .cornerRadius(20)
                        .contextMenu {
                            if let text = message.text, !text.isEmpty {
                                Button(action: {
                                    UIPasteboard.general.string = text
                                }, label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                })
                            }
                        }
                } else {
                    messageBody
                        .padding(9)
                        .foregroundColor(.primary)
                        .background(Color.accentColor)
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
                }
                
            }
            .frame(width: viewWidth * 0.7, alignment: message.isMessageSent ? .trailing : .leading)
        }
        .frame(maxWidth: .infinity, alignment: message.isMessageSent ? .trailing : .leading)
        .id(Int(message.id))
    }
    
    var messageBody: some View {
        VStack {
            
            if let replyedMessage = message.replyToMessage {
                Button(action: {
                    chatViewModel.scrollToMessageId = Int(replyedMessage.id)
                }, label: {
                    Text(replyedMessage.wrappedText)
                        .foregroundColor(Color(UIColor.darkText))
                        .lineLimit(2)
                        .padding(10)
                        .background(Color.secondary)
                        .cornerRadius(10)
                })
            }
            
            Text(message.wrappedText)
            
            ForEach(message.attachmentsArray) { attachment in
                if let name = attachment.name {
                    Button(action: {
                        chatViewModel.showAttachmentPreview(attachment)
                    }, label: {
                        HStack {
                            Label(name, systemImage: attachment.iconAsSystemImageName)
                            if chatViewModel.loadingAttachmentIds.contains(Int(attachment.id)) {
                                ProgressView()
                                    .padding(.leading)
                            }
                        }
                    })
                }
            }
            
            ForEach(message.imagesArray) { image in
                Text(image.wrappedName)
            }
        }
    }
}

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
            MessageView(message: message1, viewWidth: 450)
                .padding()
                .previewLayout(.sizeThatFits)
            
            MessageView(message: message2, viewWidth: 450)
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
