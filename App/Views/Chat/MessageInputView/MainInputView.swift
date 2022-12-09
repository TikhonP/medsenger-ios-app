//
//  MainInputView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MainInputView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    @State private var selectedMedia: ImagePickerMedia?
    @State private var showFilePickerModal = false
    @State private var showSelectImageOptions = false
    @State private var showSelectPhotosSheet = false
    @State private var showTakeImageSheet = false
    
    var body: some View {
        HStack(alignment: .bottom) {
            Button(action: {
                showSelectImageOptions = true
            }, label: {
                MessageInputButtonLabel(imageSystemName: "paperclip.circle.fill", showProgress: .constant(false))
                    .foregroundColor(.secondary.opacity(0.7))
            })
            
            TextView($chatViewModel.message, placeholder: "Message")
                .padding(.horizontal, 10)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
            
            if chatViewModel.message.isEmpty && chatViewModel.messageAttachments.isEmpty && !chatViewModel.showRecordedMessage {
                Button(action: chatViewModel.startRecording, label: {
                    MessageInputButtonLabel(imageSystemName: "waveform.circle.fill", showProgress: .constant(false))
                        .foregroundColor(.secondary.opacity(0.7))
                })
                .alert(isPresented: $chatViewModel.showAlertRecordingIsNotPermited) {
                    Alert(title: Text("Recording is not permitted"))
                }
                .alert(isPresented: $chatViewModel.showRecordingfailedAlert) {
                    Alert(title: Text("Recording failed :("))
                }
            } else {
                Button(action: chatViewModel.sendMessage, label: {
                    MessageInputButtonLabel(imageSystemName: "arrow.up.circle.fill", showProgress: $chatViewModel.showSendingMessageLoading)
                        .foregroundColor(.accentColor)
                })
            }
        }
        .actionSheet(isPresented: $showSelectImageOptions) {
            ActionSheet(title: Text("Add attachment"),
                        buttons: [
                            .default(Text("Take Photo")) {
                                showTakeImageSheet = true
                            },
                            .default(Text("Choose Photo")) {
                                showSelectPhotosSheet = true
                            },
                            .default(Text("Browse...")) {
                                showFilePickerModal = true
                            },
                            .cancel()
                        ])
        }
        .sheet(isPresented: $showSelectPhotosSheet) {
            NewImagePicker(pickedCompletionHandler: chatViewModel.addImagesAttachments)
                .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $showTakeImageSheet) {
            ImagePicker(selectedMedia: $selectedMedia, sourceType: .camera, mediaTypes: [.image, .movie], edit: false)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showFilePickerModal) {
            FilePicker(types: allDocumentsTypes, allowMultiple: true, onPicked: chatViewModel.addFilesAttachments)
                .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: selectedMedia, perform: chatViewModel.addImagesAttachments)
    }
}

#if DEBUG
struct MainInputView_Previews: PreviewProvider {
    static var previews: some View {
        MainInputView()
            .environmentObject(ChatViewModel(contractId: Int(33)))
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
#endif
