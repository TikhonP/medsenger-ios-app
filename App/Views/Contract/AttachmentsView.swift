//
//  AttachmentsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import QuickLook

@MainActor
fileprivate final class AttachmentViewModel: ObservableObject, Alertable {
    @Published var quickLookDocumentUrl: URL?
    
    @Published var loadingAttachmentIds = [Int]()
    @Published var loadingImageIds = [Int]()
    
    @Published var alert: AlertInfo?
    
    func showFilePreview(_ attachment: Attachment) async {
        if let dataPath = attachment.dataPath {
            quickLookDocumentUrl =  dataPath
        } else {
            loadingAttachmentIds.append(Int(attachment.id))
            do {
                let dataPath = try await Messages.fetchAttachmentData(attachmentId: Int(attachment.id))
                if let index = self.loadingAttachmentIds.firstIndex(of: Int(attachment.id)) {
                    self.loadingAttachmentIds.remove(at: index)
                }
                self.quickLookDocumentUrl = dataPath
            } catch {
                if let index = self.loadingAttachmentIds.firstIndex(of: Int(attachment.id)) {
                    self.loadingAttachmentIds.remove(at: index)
                }
                presentGlobalAlert()
            }
        }
    }
    
    func showImagePreview(_ image: ImageAttachment) async {
        if let dataPath = image.dataPath {
            quickLookDocumentUrl =  dataPath
        } else {
            loadingImageIds.append(Int(image.id))
            do {
                let dataPath = try await Messages.fetchImageAttachmentImage(imageAttachmentId: Int(image.id))
                if let index = self.loadingImageIds.firstIndex(of: Int(image.id)) {
                    self.loadingImageIds.remove(at: index)
                }
                self.quickLookDocumentUrl = dataPath
            } catch {
                if let index = self.loadingImageIds.firstIndex(of: Int(image.id)) {
                    self.loadingImageIds.remove(at: index)
                }
                self.presentGlobalAlert()
            }
        }
    }
}

struct AttachmentsView: View {
    private enum AttachmentsType {
        case images, files
    }
    
    @ObservedObject private var contract: Contract
    
    @FetchRequest private var attachments: FetchedResults<Attachment>
    @FetchRequest private var images: FetchedResults<ImageAttachment>
    
    @StateObject private var attachmentViewModel = AttachmentViewModel()
    
    @State private var attachmentsType: AttachmentsType = .images
    
    @State private var searchText = ""
    var query: Binding<String> {
        Binding {
            searchText
        } set: { newValue in
            searchText = newValue
            if #available(iOS 15.0, *) {
                switch attachmentsType {
                case .images:
                    images.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@ AND message.contract == %@", newValue, contract)
                case .files:
                    attachments.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@ AND message.contract == %@", newValue, contract)
                }
            }
        }
    }
    
    init(contract: Contract) {
        _attachments = FetchRequest<Attachment>(
            entity: Attachment.entity(),
            sortDescriptors: [NSSortDescriptor(key: "message.sent", ascending: true)],
            predicate: NSPredicate(format: "message.contract == %@", contract),
            animation: .default
        )
        _images = FetchRequest<ImageAttachment>(
            entity: ImageAttachment.entity(),
            sortDescriptors: [NSSortDescriptor(key: "message.sent", ascending: true)],
            predicate: NSPredicate(format: "message.contract == %@", contract),
            animation: .default
        )
        self.contract = contract
    }
    
    var body: some View {
        ZStack {
            switch attachmentsType {
            case .images:
                ZStack {
                    if images.isEmpty {
                        Text("AttachmentsView.noImages", comment: "There is no images")
                    } else {
                        List(images) { image in
                            Button {
                                Task {
                                    await attachmentViewModel.showImagePreview(image)
                                }
                            } label: {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .foregroundColor(.accentColor)
                                        if attachmentViewModel.loadingImageIds.contains(Int(image.id)) {
                                            ProgressView()
                                                .padding(7)
                                        } else {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(.systemBackground)
                                                .padding(7)
                                        }
                                    }
                                    .frame(height: 30)
                                    .animation(.default, value: attachmentViewModel.loadingImageIds)
                                    
                                    Text(image.wrappedName)
                                    
                                    if let message = image.message {
                                        Spacer()
                                        if message.isMessageSent {
                                            Text("AttachmentsView.You", comment: "You")
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text(message.wrappedAuthor)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .searchableIos15Only(text: query)
                    }
                }
                .transition(.move(edge: .leading))
            case.files:
                ZStack {
                    if attachments.isEmpty {
                        Text("AttachmentsView.noAttachments", comment: "There is no attachments")
                    } else {
                        List(attachments) { attachment in
                            if let message = attachment.message, !message.isVoiceMessage {
                                Button {
                                    Task {
                                        await attachmentViewModel.showFilePreview(attachment)
                                    }
                                } label: {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .foregroundColor(.accentColor)
                                            if attachmentViewModel.loadingAttachmentIds.contains(Int(attachment.id)) {
                                                ProgressView()
                                                    .padding(7)
                                            } else {
                                                Image(systemName: attachment.iconAsSystemImageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.systemBackground)
                                                    .padding(7)
                                            }
                                        }
                                        .frame(height: 30)
                                        .animation(.default, value: attachmentViewModel.loadingAttachmentIds)
                                        
                                        Text(attachment.wrappedName)
                                        
                                        Spacer()
                                        if let message = attachment.message {
                                            if message.isMessageSent {
                                                Text("AttachmentsView.You", comment: "You")
                                                    .foregroundColor(.secondary)
                                            } else {
                                                Text(message.wrappedAuthor)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .searchableIos15Only(text: query)
                    }
                }
                .transition(.move(edge: .trailing))
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("AttachmentsView.AttachmentsType.Picker", selection: $attachmentsType) {
                    Text("AttachmentsView.images", comment: "Images").tag(AttachmentsType.images)
                    Text("AttachmentsView.files", comment: "Files").tag(AttachmentsType.files)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .quickLookPreview($attachmentViewModel.quickLookDocumentUrl)
        .animation(.default, value: attachmentsType)
        .alert(item: $attachmentViewModel.alert) { $0.alert }
    }
}

#if DEBUG
struct AttachmentsView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentsView(contract: ContractPreviews.contractForPatientChatRowPreview)
    }
}
#endif
