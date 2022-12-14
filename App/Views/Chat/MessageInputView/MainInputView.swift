//
//  MainInputView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MainInputView: View {
    @EnvironmentObject private var messageInputViewModel: MessageInputViewModel
    
    @State private var selectedMedia: ImagePickerMedia?
    @State private var showFilePickerModal = false
    @State private var showSelectImageOptions = false
    @State private var showSelectPhotosSheet = false
    @State private var showTakeImageSheet = false
    
    @State private var calculatedHeight: CGFloat = .zero
    @State private var isScrollingEnabled = false
    @State private var clearText = false
    
    private static let maxHeightConstant: CGFloat = 250
    
    var body: some View {
        HStack(alignment: .bottom) {
            Button(action: {
                showSelectImageOptions = true
            }, label: {
                MessageInputButtonLabel(imageSystemName: "paperclip.circle.fill", showProgress: .constant(false))
                    .foregroundColor(.secondary.opacity(0.7))
            })
            .actionSheet(isPresented: $showSelectImageOptions) {
                ActionSheet(title: Text("MainInputView.addAttachment.ActionSheetTitle", comment: "Add attachment"),
                            buttons: [
                                .default(Text("MainInputView.TakePhoto.Button", comment: "Take Photo")) {
                                    showTakeImageSheet = true
                                },
                                .default(Text("MainInputView.ChoosePhoto.Button", comment: "Choose Photo")) {
                                    showSelectPhotosSheet = true
                                },
                                .default(Text("MainInputView.Browse.Button", comment: "Browse...")) {
                                    showFilePickerModal = true
                                },
                                .cancel()
                            ])
            }
            .sheet(isPresented: $showSelectPhotosSheet) {
                NewImagePicker(pickedCompletionHandler: {
                    messageInputViewModel.addImagesAttachments($0)
                })
                .edgesIgnoringSafeArea(.all)
            }
            .fullScreenCover(isPresented: $showTakeImageSheet) {
                ImagePicker(selectedMedia: $selectedMedia, sourceType: .camera, mediaTypes: [.image, .movie], edit: false)
                    .edgesIgnoringSafeArea(.all)
            }
            .sheet(isPresented: $showFilePickerModal) {
                FilePicker(types: allDocumentsTypes, allowMultiple: true, onPicked: { media in
                    Task(priority: .userInitiated) {
                        await messageInputViewModel.addFilesAttachments(media)
                    }
                })
                .edgesIgnoringSafeArea(.all)
            }
            .onChange(of: selectedMedia, perform: {
                messageInputViewModel.addImagesAttachments($0)
            })
            
            UIKitTextViewRepresentable(text: $messageInputViewModel.message, calculatedHeight: $calculatedHeight, clearText: $clearText, isScrollingEnabled: isScrollingEnabled, onEditingChanged: {
                messageInputViewModel.saveMessageDraft()
            })
            .frame(height: isScrollingEnabled ? MainInputView.maxHeightConstant : calculatedHeight)
            .background(
                Text("MainInputView.Message.TextView", comment: "Message input placeholder")
                    .foregroundColor(Color(.placeholderText))
                    .padding(.leading, 14)
                    .opacity(messageInputViewModel.message.isEmpty ? 1 : 0),
                alignment: .leading
            )
            .onChange(of: calculatedHeight) { newValue in
                if newValue < MainInputView.maxHeightConstant {
                    isScrollingEnabled = false
                } else {
                    isScrollingEnabled = true
                }
            }
            .onChange(of: messageInputViewModel.message, perform: { newValue in
                if newValue.isEmpty {
                    clearText = true
                }
            })
            .background(Color.systemBackground)
            .clipShape(RoundedRectangle(cornerSize: .init(width: 20, height: 20)))
            
            Group {
                if messageInputViewModel.message.isEmpty && messageInputViewModel.messageAttachments.isEmpty && !messageInputViewModel.showRecordedMessage {
                    Button {
                        Task(priority: .userInitiated) {
                            messageInputViewModel.startRecording
                        }
                    } label: {
                        MessageInputButtonLabel(imageSystemName: "waveform.circle.fill", showProgress: .constant(false))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                } else {
                    Button {
                        Task(priority: .userInitiated) {
                            await messageInputViewModel.sendMessage()
                        }
                    } label: {
                        MessageInputButtonLabel(imageSystemName: "arrow.up.circle.fill", showProgress: $messageInputViewModel.showSendingMessageLoading)
                            .foregroundColor(Color("medsengerBlue"))
                    }
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                }
            }
            .animation(.spring(), value: messageInputViewModel.message)
            .animation(.spring(), value: messageInputViewModel.messageAttachments)
        }
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
