//
//  InputAttachmentsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct InputAttachmentsView: View {
    @EnvironmentObject private var messageInputViewModel: MessageInputViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack{
                ForEach(messageInputViewModel.messageAttachments) { attachment in
                    TextInputAttachmentView(attachment: attachment)
                }
            }
        }
    }
}

#if DEBUG
struct InputAttachmentsView_Previews: PreviewProvider {
    static var previews: some View {
        InputAttachmentsView()
    }
}
#endif
