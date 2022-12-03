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
    
    @State private var waveformImage: DSImage = DSImage()
    @State private var waveformImageProgress: DSImage = DSImage()
    
    @State private var imagePreviewSucceded = true
    
    @FetchRequest private var attachments: FetchedResults<Attachment>
    
    init(message: Message) {
        self.message = message
        let fetchRequest = Attachment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "message == %@", message)
        fetchRequest.sortDescriptors = []
        fetchRequest.fetchLimit = 1
        _attachments = FetchRequest(fetchRequest: fetchRequest)
    }
    
    private var image: some View {
#if os(macOS)
        Image(nsImage: waveformImage).resizable()
#else
        Image(uiImage: waveformImage).resizable()
#endif
    }
    
    private var imageProgress: some View {
#if os(macOS)
        Image(nsImage: waveformImageProgress).resizable()
#else
        Image(uiImage: waveformImageProgress).resizable()
#endif
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
                        ZStack(alignment: .leading) {
                            voiceMessageWaveFormStable(audioFileURL: audioFileURL)
                            if chatViewModel.isAudioMessagePlayingWithId == Int(attachment.id) {
                                ZStack {
                                    voiceMessageWaveFormProgress(audioFileURL: audioFileURL)
                                        .mask(
                                            GeometryReader { geometry in
                                                HStack {
                                                    Rectangle().frame(width: geometry.size.width * chatViewModel.playingAudioProgress)
                                                    Spacer()
                                                }
                                            }
                                        )
                                }
                                .animation(.default, value: chatViewModel.playingAudioProgress)
                            }
                        }
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
    
    func voiceMessageWaveFormStable(audioFileURL: URL) -> some View {
        ZStack {
            if imagePreviewSucceded {
                GeometryReader { reader in
                    image
                        .onAppear{
                            guard waveformImage.size == .zero else { return }
                            let waveformImageDrawer = WaveformImageDrawer()
                            waveformImageDrawer.waveformImage(fromAudioAt: audioFileURL, with: .init(
                                size: reader.size,
                                style: .striped(.init(color: UIColor.black, width: 3)),
                                position: .middle
                            )) { image in
                                // need to jump back to main queue
                                DispatchQueue.main.async {
                                    if let image = image {
                                        waveformImage = image
                                    } else {
                                        imagePreviewSucceded = false
                                    }
                                }
                            }
                        }
                }
            } else {
                Text("Failed to preview voice message")
            }
        }
    }
    
    func voiceMessageWaveFormProgress(audioFileURL: URL) -> some View {
        ZStack {
            if imagePreviewSucceded {
                GeometryReader { reader in
                    imageProgress
                        .onAppear{
                            guard waveformImageProgress.size == .zero else { return }
                            let waveformImageDrawer = WaveformImageDrawer()
                            waveformImageDrawer.waveformImage(fromAudioAt: audioFileURL, with: .init(
                                size: reader.size,
                                style: .striped(.init(color: UIColor.white, width: 3)),
                                position: .middle
                            )) { image in
                                // need to jump back to main queue
                                DispatchQueue.main.async {
                                    if let image = image {
                                        waveformImageProgress = image
                                    } else {
                                        imagePreviewSucceded = false
                                    }
                                }
                            }
                        }
                }
            } else {
                Text("Failed to preview voice message")
            }
        }
    }
}

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
