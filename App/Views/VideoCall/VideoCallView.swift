//
//  VideoCallView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct VideoCallView: View {
    @StateObject private var videoCallViewModel: VideoCallViewModel
    
    @FetchRequest private var contracts: FetchedResults<Contract>
    
    init(contractId: Int, contentViewModel: ContentViewModel) {
        _videoCallViewModel = StateObject(wrappedValue: VideoCallViewModel(contractId: contractId, contentViewModel: contentViewModel))
        _contracts = FetchRequest<Contract>(
            entity: Contract.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "id == %ld", contractId),
            animation: .default
        )
    }
    
    var body: some View {
        Group {
            if let contract = contracts.first {
                ZStack {
                    Color.systemBackground
                        .edgesIgnoringSafeArea(.all)
                    switch videoCallViewModel.rtcState {
                    case .new, .checking:
                        WaitingCallView(contract: contract)
                            .environmentObject(videoCallViewModel)
                    case .connected, .completed:
                        CallingView(contract: contract)
                            .environmentObject(videoCallViewModel)
                    default:
                        Text("VideoCallView.CallError", comment: "Call error")
                    }
                }
                .onAppear { videoCallViewModel.videoCallViewAppear() }
            }
        }
    }
}

#if DEBUG
struct VideoCallView_Previews: PreviewProvider {
    static var previews: some View {
        VideoCallView(contractId: 1234, contentViewModel: ContentViewModel())
    }
}
#endif
