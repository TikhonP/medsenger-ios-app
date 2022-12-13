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
                        if chatViewModel.isAudioMessagePlayingWithId != Int(attachment.id) {
                            Button(action: {
                                chatViewModel.startPlaying(audioFileURL, attachmentId: Int(attachment.id))
                            }, label: {
                                Image(systemName: "play.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(10)
                            })
                        } else {
                            Button(action: {
                                chatViewModel.stopPlaying()
                            }, label: {
                                Image(systemName: "stop.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(10)
                            })
                        }
                        AudioPlayerView(
                            audioFileUrl: audioFileURL,
                            isPlaying: Binding<Bool>(
                                get: {
                                    chatViewModel.isAudioMessagePlayingWithId == Int(attachment.id)
                                },
                                set: { _ in }
                            ),
                            playingAudioProgress: $chatViewModel.playingAudioProgress)
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        chatViewModel.fetchAttachment(attachment)
                    }
                }
            }
        }
        .frame(height: 50)
    }
}

#if DEBUG
struct VoiceMessageView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var message1: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(for: context)
    }()
    
    static var previews: some View {
        VoiceMessageView(message: message1)
    }
}
#endif
