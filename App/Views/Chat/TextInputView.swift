//
//  TextInputView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 30.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

fileprivate struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

struct TextInputView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    @State var textEditorHeight: CGFloat = 20
    
    private var maxHeight: CGFloat = 250
    private var buttonsHeight: CGFloat = 33
    
    var body: some View {
        VStack {
            ZStack {
                if let replyToMessage = chatViewModel.replyToMessage {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.left")
                            .resizable()
                            .scaledToFit()
                            .padding(5)
                            .frame(width: buttonsHeight, height: buttonsHeight)
                        Spacer()
                        Text(replyToMessage.wrappedText)
                            .lineLimit(4)
                            .onTapGesture {
                                chatViewModel.scrollToMessageId = Int(replyToMessage.id)
                            }
                        Spacer()
                        Button(action: {
                            chatViewModel.replyToMessage = nil
                        }, label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .padding(7)
                                .frame(width: buttonsHeight, height: buttonsHeight)
                        })
                    }
                }
            }
            .transition(.slide)
            .animation(.default, value: chatViewModel.replyToMessage)
    
            HStack {
                VStack {
                    Spacer()
                    leadingButtons
                        .padding(.bottom, 8)
                }
                .frame(height: min(textEditorHeight, maxHeight))
                textInputView
                VStack {
                    Spacer()
                    trailingButtons
                        .padding(.bottom, 8)
                }
                .frame(height: min(textEditorHeight, maxHeight))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .actionSheet(isPresented: $chatViewModel.showSelectImageOptions) {
            ActionSheet(title: Text("Choose a photo"),
                        buttons: [
                            .default(Text("Pick from library")) {
                                chatViewModel.showSelectPhotosSheet = true
                            },
                            .default(Text("Take a photo")) {
                                chatViewModel.showTakeImageSheet = true
                            },
                            .cancel()
                        ])
        }
        .sheet(isPresented: $chatViewModel.showSelectPhotosSheet) {
            ImagePicker(selectedImage: $chatViewModel.selectedImage, sourceType: .photoLibrary)
                .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $chatViewModel.showTakeImageSheet) {
            ZStack {
                Color.black
                ImagePicker(selectedImage: $chatViewModel.selectedImage, sourceType: .camera)
                    .padding(.bottom, 40)
                    .padding(.top)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onChange(of: chatViewModel.selectedImage) { newValue in
            chatViewModel.isImageAdded = true
        }
    }
    
    var leadingButtons: some View {
        ZStack {
            if chatViewModel.isImageAdded {
                Button(action: {
                    chatViewModel.isImageAdded = false
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: buttonsHeight, height: buttonsHeight)
                })
            } else {
                Button(action: {
                    chatViewModel.showSelectImageOptions = true
                }, label: {
                    Image(systemName: "camera.circle.fill")
                        .resizable()
                        .frame(width: buttonsHeight, height: buttonsHeight)
                })
            }
        }
        .transition(.opacity)
    }
    
    var trailingButtons: some View {
        ZStack {
            if chatViewModel.message.isEmpty && !chatViewModel.isImageAdded && !chatViewModel.showRecordedMessage {
                if chatViewModel.isRecordingVoiceMessage {
                    Button(action: { chatViewModel.finishRecording(success: true) }, label: {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .frame(width: buttonsHeight, height: buttonsHeight)
                            .foregroundColor(.primary)
                    })
                } else {
                    Button(action: chatViewModel.startRecording, label: {
                        Image(systemName: "waveform.circle.fill")
                            .resizable()
                            .frame(width: buttonsHeight, height: buttonsHeight)
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
                        .resizable()
                        .frame(width: buttonsHeight, height: buttonsHeight)
                        .foregroundColor(.accentColor)
                })
            }
        }
        .transition(.opacity)
    }
    
    var textInputView: some View {
        ZStack(alignment: .leading) {
            Text(chatViewModel.message)
                .font(.system(.body))
                .foregroundColor(.clear)
                .padding(chatViewModel.message.isEmpty ? 9 : 6)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self, value: $0.frame(in: .local).size.height)
                })
            
            TextEditor(text: $chatViewModel.message)
                .font(.system(.body))
                .frame(height: min(textEditorHeight, maxHeight))
                .opacity(chatViewModel.message.isEmpty ? 0.25 : 1)
                .padding(.horizontal, 9)
                .overlay(RoundedRectangle(cornerSize: .init(width: 20, height: 20)).stroke(Color.secondary))
        }
        .onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
    }
}

struct TextInputView_Previews: PreviewProvider {
    //    static let persistence = PersistenceController.preview
    //
    //    static var contract1: Contract = {
    //        let context = persistence.container.viewContext
    //        return Contract.createSampleContract1(for: context)
    //    }()
    //
    static var previews: some View {
        TextInputView()
        //            .environment(\.managedObjectContext, persistence.container.viewContext)
            .environmentObject(ChatViewModel(contractId: Int(33)))
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
