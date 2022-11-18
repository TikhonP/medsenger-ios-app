//
//  AttachmentsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import QuickLook

final class AttachmentViewModel: ObservableObject {
    @Published var quickLookDocumentUrl: URL?
    @Published var loadingAttachmentIds = [Int]()
    
    func showPreview(_ attachment: Attachment) {
        if let dataPath = attachment.dataPath {
            quickLookDocumentUrl = dataPath
        } else {
            loadingAttachmentIds.append(Int(attachment.id))
            Messages.shared.fetchAttachmentData(attachmentId: Int(attachment.id)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let index = self.loadingAttachmentIds.firstIndex(of: Int(attachment.id)) {
                        self.loadingAttachmentIds.remove(at: index)
                    }
                    self.quickLookDocumentUrl = Attachment.get(id: Int(attachment.id))?.dataPath
                }
            }
        }
    }
}

struct AttachmentsView: View {
    @ObservedObject var contract: Contract
    
    @FetchRequest private var attachments: FetchedResults<Attachment>
    
    @StateObject private var attachmentViewModel = AttachmentViewModel()
    
    @State private var searchText = ""
    var query: Binding<String> {
        Binding {
            searchText
        } set: { newValue in
            searchText = newValue
            if #available(iOS 15.0, *) {
                attachments.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@ AND message.contract == %@", newValue, contract)
            }
        }
    }
    
    init(contract: Contract) {
        _attachments = FetchRequest<Attachment>(
            entity: Attachment.entity(),
            sortDescriptors: [NSSortDescriptor(key: "message.sent", ascending: true)],
            predicate: NSPredicate(format: "message.contract == %@", contract),
            animation: .easeIn
        )
        self.contract = contract
    }
    
    var body: some View {
        ZStack {
            if attachments.isEmpty {
                Text("There is no attachments")
            } else {
                List(attachments) { attachment in
                    if let name = attachment.name {
                        Button(action: {
                            attachmentViewModel.showPreview(attachment)
                        }, label: {
                            HStack {
                                Label(name, systemImage: attachment.iconAsSystemImageName)
                                if attachmentViewModel.loadingAttachmentIds.contains(Int(attachment.id)) {
                                    ProgressView()
                                        .padding(.leading)
                                }
                            }
                        })
                    }
                }
            }
        }
        .navigationTitle("Attachments")
        .quickLookPreview($attachmentViewModel.quickLookDocumentUrl)
        .deprecatedSearchable(text: query)
    }
}

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
