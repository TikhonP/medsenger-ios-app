//
//  RecordedVoiceMessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 12.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct RecordedVoiceMessageView: View {
     @EnvironmentObject private var messageInputViewModel: MessageInputViewModel
     @Environment(\.colorScheme) var colorScheme
     
     var body: some View {
          HStack {
               Button(action: {
                    messageInputViewModel.showRecordedMessage = false
               }, label: {
                    Image(systemName: "trash")
                         .resizable()
                         .scaledToFit()
                         .frame(height: 25)
                         .foregroundColor(colorScheme == .light ? .accentColor : .primary)
               })
               
               HStack {
                    ZStack {
                         if messageInputViewModel.isVoiceMessagePlaying {
                              Button(action: messageInputViewModel.stopPlaying, label: {
                                   Image(systemName: "stop.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.systemBackground)
                                        .padding(.leading)
                                        .padding([.vertical, .trailing], 10)
                              })
                         } else {
                              Button(action: {
                                   Task {
                                        await messageInputViewModel.startPlayingRecordedVoiceMessage()
                                   }
                              }, label: {
                                   Image(systemName: "play.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.systemBackground)
                                        .padding(.leading)
                                        .padding([.vertical, .trailing], 10)
                              })
                         }
                    }
                    if let recordedMessageUrl = messageInputViewModel.recordedMessageUrl {
                         AudioPlayerView(
                              audioFileUrl: recordedMessageUrl,
                              isPlaying: $messageInputViewModel.isVoiceMessagePlaying,
                              playingAudioProgress: $messageInputViewModel.playingAudioProgress,
                              mainColor: .gray,
                              progressColor: .systemBackground,
                              width: 2
                         )
                         .padding(.trailing)
                         .padding(.vertical, 10)
                    }
               }
               .frame(height: 38)
               .background(colorScheme == .light ? Color.accentColor : Color.white)
               .clipShape(RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
               
               Button(action: {
                    Task {
                         await messageInputViewModel.sendVoiceMessage()
                    }
               }, label: {
                    MessageInputButtonLabel(imageSystemName: "arrow.up.circle.fill", showProgress: $messageInputViewModel.showSendingMessageLoading)
                         .foregroundColor(.accentColor)
               })
          }
     }
}

struct RecordedVoiceMessageView_Previews: PreviewProvider {
     static var previews: some View {
          RecordedVoiceMessageView()
     }
}
