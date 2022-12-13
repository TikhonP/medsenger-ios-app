//
//  RecordedVoiceMessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 12.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct RecordedVoiceMessageView: View {
     @EnvironmentObject private var chatViewModel: ChatViewModel
     @Environment(\.colorScheme) var colorScheme
     
     var body: some View {
          HStack {
               Button(action: {
                    chatViewModel.showRecordedMessage = false
               }, label: {
                    Image(systemName: "trash")
                         .resizable()
                         .scaledToFit()
                         .frame(height: 25)
                         .foregroundColor(colorScheme == .light ? .accentColor : .primary)
               })
               
               HStack {
                    ZStack {
                         if chatViewModel.isVoiceMessagePlaying {
                              Button(action: chatViewModel.stopPlaying, label: {
                                   Image(systemName: "stop.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.init(UIColor.systemBackground))
                                        .padding(.leading)
                                        .padding([.vertical, .trailing], 10)
                              })
                         } else {
                              Button(action: chatViewModel.startPlayingRecordedVoiceMessage, label: {
                                   Image(systemName: "play.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.init(UIColor.systemBackground))
                                        .padding(.leading)
                                        .padding([.vertical, .trailing], 10)
                              })
                         }
                    }
                    if let recordedMessageUrl = chatViewModel.recordedMessageUrl {
                         AudioPlayerView(
                              audioFileUrl: recordedMessageUrl,
                              isPlaying: $chatViewModel.isVoiceMessagePlaying,
                              playingAudioProgress: $chatViewModel.playingAudioProgress,
                              mainColor: .gray,
                              progressColor: .init(UIColor.systemBackground),
                              width: 2
                         )
                         .padding(.trailing)
                         .padding(.vertical, 10)
                    }
//                    Text("0:01")
//                         .padding(.trailing)
//                         .padding([.vertical, .leading], 10)
//                         .foregroundColor(Color(UIColor.systemBackground))
               }
               .frame(height: 38)
               .background(colorScheme == .light ? Color.accentColor : Color.white)
               .clipShape(RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
               
               Button(action: chatViewModel.sendVoiceMessage, label: {
                    MessageInputButtonLabel(imageSystemName: "arrow.up.circle.fill", showProgress: $chatViewModel.showSendingMessageLoading)
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
