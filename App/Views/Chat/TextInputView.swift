//
//  TextInputView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct TextInputView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "camera.fill")
                .font(.title)
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .stroke()
                HStack {
                    if chatViewModel.showRecordedMessage {
                        if chatViewModel.isVoiceMessagePlaying {
                            Button(action: chatViewModel.stopPlaying, label: {
                                Image(systemName: "pause.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.primary)
                            })
                            Spacer()
                            Text("Playing audio...")
                        } else {
                            Button(action: chatViewModel.startPlayingRecordedVoiceMessage, label: {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.primary)
                            })
                            Spacer()
                            Text("Play audio")
                        }
                        Spacer()
                        Button(action: chatViewModel.sendVoiceMessage, label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        })
                    } else {
                        if chatViewModel.isRecordingVoiceMessage {
                            Text("Recording...")
                        } else {
                            TextField(
                                "Write a message",
                                text: $chatViewModel.message,
                                onCommit: chatViewModel.sendMessage
                            )
                            .font(.headline)
                        }
                        Spacer()
                        ZStack {
                            if chatViewModel.message.isEmpty {
                                if chatViewModel.isRecordingVoiceMessage {
                                    Button(action: { chatViewModel.finishRecording(success: true) }, label: {
                                        Image(systemName: "stop.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.primary)
                                    })
                                } else {
                                    Button(action: chatViewModel.startRecording, label: {
                                        Image(systemName: "waveform.circle.fill")
                                            .font(.title)
                                            .foregroundColor(chatViewModel.isRecordingVoiceMessage ? .primary : .secondary)
                                    })
                                    .alert(isPresented: $chatViewModel.showAlertRecordingIsNotPermited) {
                                        Alert(title: Text("Recording is not permitted"))
                                    }
                                    .alert(isPresented: $chatViewModel.showRecordingfailedAlert) {
                                        Alert(title: Text("Recording failed :("))
                                    }
                                }
                            } else {
                                Button(action: chatViewModel.sendMessage, label: {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                })
                            }
                        }
                        .transition(.slide)
                        .animation(.easeInOut)
                    }
                }
                .padding(EdgeInsets(top: 3, leading: 12, bottom: 3, trailing: 3))
            }
            .frame(height: 33)
        }
        .foregroundColor(Color(.systemGray))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Color(UIColor.systemBackground).opacity(0.95).edgesIgnoringSafeArea(.bottom)
        )
        .deprecatedScrollDismissesKeyboard()
    }
}

struct TextInputView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var previews: some View {
        TextInputView()
            .environment(\.managedObjectContext, persistence.container.viewContext)
            .environmentObject(ChatViewModel(contractId: Int(contract1.id)))
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
