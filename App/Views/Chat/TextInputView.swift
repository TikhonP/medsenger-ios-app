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
    
    @State var showFilePickerModal = false
    
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
            
            ZStack {
                if !chatViewModel.addedImages.isEmpty {
                    ScrollView(.horizontal) {
                        HStack{
                            ForEach(chatViewModel.addedImages) { attachment in
                                TextInputAttachmentView(attachment: attachment)
                                    .padding(.trailing)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .transition(.slide)
            .animation(.default, value: chatViewModel.addedImages)
            
            HStack {
                VStack {
                    Spacer()
                    leadingButtons
                        .frame(height: buttonsHeight)
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
                            .default(Text("Pick from documents")) {
                                showFilePickerModal = true
                            },
                            .cancel()
                        ])
        }
        .sheet(isPresented: $chatViewModel.showSelectPhotosSheet) {
            NewImagePicker { selectedMedia in
                let chatViewAttachment: ChatViewAttachment
                switch selectedMedia.type {
                case .image:
                    chatViewAttachment = ChatViewAttachment(data: selectedMedia.data, extention: selectedMedia.extention, realFilename: selectedMedia.realFilename, type: .image)
                case .movie:
                    chatViewAttachment = ChatViewAttachment(data: selectedMedia.data, extention: selectedMedia.extention, realFilename: selectedMedia.realFilename, type: .video)
                }
                chatViewModel.addedImages.append(chatViewAttachment)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $chatViewModel.showTakeImageSheet) {
            ImagePicker(selectedMedia: $chatViewModel.selectedMedia, sourceType: .camera, mediaTypes: [.image, .movie], edit: false)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showFilePickerModal) {
            FilePicker(types: allDocumentsTypes, allowMultiple: true, onPicked: { urls in
                for fileURL in urls {
                    do {
                        if fileURL.startAccessingSecurityScopedResource() {
                            let data = try Data(contentsOf: fileURL)
                            chatViewModel.addedImages.append(ChatViewAttachment(
                                data: data, extention: fileURL.pathExtension, realFilename: fileURL.lastPathComponent, type: .file))
                            fileURL.stopAccessingSecurityScopedResource()
                        }
                    } catch {
                        print("Failed to load file: \(error.localizedDescription)")
                    }
                }
            })
            .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: chatViewModel.selectedMedia) { newValue in
            guard let selectedMedia = newValue else {
                return
            }
            let chatViewAttachment: ChatViewAttachment
            switch selectedMedia.type {
            case .image:
                chatViewAttachment = ChatViewAttachment(data: selectedMedia.data, extention: selectedMedia.extention, realFilename: selectedMedia.realFilename, type: .image)
            case .movie:
                chatViewAttachment = ChatViewAttachment(data: selectedMedia.data, extention: selectedMedia.extention, realFilename: selectedMedia.realFilename, type: .video)
            }
            chatViewModel.addedImages.append(chatViewAttachment)
        }
    }
    
    var leadingButtons: some View {
        Button(action: {
            chatViewModel.showSelectImageOptions = true
        }, label: {
            Image(systemName: "paperclip.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.secondary)
//
        })
    }
    
    var trailingButtons: some View {
        ZStack {
            if chatViewModel.message.isEmpty && chatViewModel.addedImages.isEmpty && !chatViewModel.showRecordedMessage {
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
