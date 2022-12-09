//
//  WaitingCallView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct WaitingCallView: View {
    @ObservedObject var contract: Contract
    
    @EnvironmentObject private var videoCallViewModel: VideoCallViewModel
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                if let avatarData = contract.avatar {
                    Image(data: avatarData)?
                        .resizable()
                } else {
                    ProgressView()
                }
            }
            .frame(width: 95, height: 95)
            .clipShape(Circle())
            .padding(.bottom)
            Text(contract.wrappedName)
                .font(.largeTitle)
            if videoCallViewModel.answered {
                switch videoCallViewModel.rtcState {
                case .new:
                    Text("Loading...")
                case .checking:
                    Text("Connecting...")
                default:
                    Text("Connecting...")
                }
            } else {
                Text("Calling...")
            }
            Spacer()
            if videoCallViewModel.isCaller {
                Button(action: videoCallViewModel.hangUp, label: {
                    Image(systemName: "phone.down.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.red)
                        .shadow(radius: 30)
                        .padding(.bottom)
                })
            } else {
                HStack {
                    Spacer()
                    Button(action: videoCallViewModel.answer, label: {
                        Image(systemName: "phone.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.green)
                            .shadow(radius: 30)
                            .padding(.bottom)
                    })
                    Spacer()
                    Button(action: videoCallViewModel.dismiss, label: {
                        Image(systemName: "phone.down.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.red)
                            .shadow(radius: 30)
                            .padding(.bottom)
                    })
                    Spacer()
                }
            }
        }
    }
}

#if DEBUG
struct WaitingCallView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var previews: some View {
        WaitingCallView(contract: contract1)
    }
}
#endif
