//
//  VoiceMessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct VoiceMessageView: View {
    @ObservedObject var message: Message
    
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    @FetchRequest private var attachments: FetchedResults<Attachment>
    
    init(message: Message) {
        self.message = message
        let fetchRequest = Attachment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "message == %@", message)
        fetchRequest.sortDescriptors = []
        fetchRequest.fetchLimit = 1
        _attachments = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        ZStack {
            if let attachment = attachments.first {
                if let audioFileURL = attachment.dataPath {
                    HStack {
                        ZStack {
                            if chatViewModel.isAudioMessagePlayingWithId != Int(attachment.id) {
                                Button(action: {
                                    Task {
                                        await chatViewModel.startPlaying(audioFileURL, attachmentId: Int(attachment.id))
                                    }
                                }, label: {
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                })
                                .transition(.scale)
                            } else {
                                Button(action: {
                                    chatViewModel.stopPlaying()
                                }, label: {
                                    Image(systemName: "stop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                })
                                .transition(.scale)
                            }
                        }
                        .animation(.spring().speed(1.5), value: chatViewModel.isAudioMessagePlayingWithId)
                        
                        AudioPlayerView(
                            audioFileUrl: audioFileURL,
                            isPlaying: Binding<Bool>(
                                get: {
                                    chatViewModel.isAudioMessagePlayingWithId == Int(attachment.id)
                                },
                                set: { _ in }
                            ),
                            playingAudioProgress: $chatViewModel.playingAudioProgress,
                            mainColor: .secondary,
                            progressColor: .primary
                        )
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        Task {
                            await chatViewModel.fetchAttachment(attachment)
                        }
                    }
                }
            }
        }
        .frame(height: 30)
        .padding(10)
    }
}

#if DEBUG
struct VoiceMessageView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var message: Message = {
        let context = persistence.container.viewContext
        let m = Message.getSampleVoiceMessage(for: context)
        PersistenceController.save(for: context)
        return m
    }()
    
    static var previews: some View {
        MessageView(viewWidth: 450, message: message)
            .padding()
            .previewLayout(.sizeThatFits)
            .environment(\.managedObjectContext, persistence.container.viewContext)
    }
}
#endif
