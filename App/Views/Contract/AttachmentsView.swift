//
//  AttachmentsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import QuickLook

fileprivate final class AttachmentViewModel: ObservableObject {
    @Published var quickLookDocumentUrl: URL?
    
    @Published var loadingAttachmentIds = [Int]()
    @Published var loadingImageIds = [Int]()
    
    func showFilePreview(_ attachment: Attachment) {
        if let dataPath = attachment.dataPath {
            quickLookDocumentUrl =  dataPath
        } else {
            loadingAttachmentIds.append(Int(attachment.id))
            Messages.shared.fetchAttachmentData(attachmentId: Int(attachment.id)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let index = self.loadingAttachmentIds.firstIndex(of: Int(attachment.id)) {
                        self.loadingAttachmentIds.remove(at: index)
                    }
                    guard let dataPath = Attachment.get(id: Int(attachment.id))?.dataPath else {
                        return
                    }
                    self.quickLookDocumentUrl = dataPath
                }
            }
        }
    }
    
    func showImagePreview(_ image: ImageAttachment) {
        if let dataPath = image.dataPath {
            quickLookDocumentUrl = dataPath
        } else {
            loadingImageIds.append(Int(image.id))
            Messages.shared.fetchImageAttachmentImage(imageAttachmentId: Int(image.id)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let index = self.loadingImageIds.firstIndex(of: Int(image.id)) {
                        self.loadingImageIds.remove(at: index)
                    }
                    guard let dataPath = ImageAttachment.get(id: Int(image.id))?.dataPath else {
                        return
                    }
                    self.quickLookDocumentUrl = dataPath
                }
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
                        Text("There is no images")
                    } else {
                        List(images) { image in
                            Button {
                                attachmentViewModel.showImagePreview(image)
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
                                                .foregroundColor(.init(UIColor.systemBackground))
                                                .padding(7)
                                        }
                                    }
                                    .frame(height: 30)
                                    .animation(.default, value: attachmentViewModel.loadingImageIds)
                                    
                                    Text(image.wrappedName)
                                }
                            }
                        }
                    }
                }
                .transition(.move(edge: .leading))
            case.files:
                ZStack {
                    if attachments.isEmpty {
                        Text("There is no attachments")
                    } else {
                        List(attachments) { attachment in
                            if let message = attachment.message, !message.isVoiceMessage {
                                Button {
                                    attachmentViewModel.showFilePreview(attachment)
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
                                                    .foregroundColor(.init(UIColor.systemBackground))
                                                    .padding(7)
                                            }
                                        }
                                        .frame(height: 30)
                                        .animation(.default, value: attachmentViewModel.loadingAttachmentIds)
                                        
                                        Text(attachment.wrappedName)
                                    }
                                }
                            }
                        }
                    }
                }
                .transition(.move(edge: .trailing))
            }
        }
        .navigationTitle("Media")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Attachments Type", selection: $attachmentsType) {
                    Text("Images").tag(AttachmentsType.images)
                    Text("Files").tag(AttachmentsType.files)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .searchableIos16Only(text: query)
        .quickLookPreview($attachmentViewModel.quickLookDocumentUrl)
        .animation(.default, value: attachmentsType)
    }
}

#if DEBUG
struct AttachmentsView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var previews: some View {
        AttachmentsView(contract: contract1)
    }
}
#endif
