//
//  CallingView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct CallingView: View {
    @ObservedObject var contract: Contract
    
    @EnvironmentObject private var videoCallViewModel: VideoCallViewModel
    
    var body: some View {
        VStack {
            ZStack {
                RemoteVideoView(webRTCClient: videoCallViewModel.webRTCClient)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        if videoCallViewModel.isVideoOn {
                            LocalVideoView(webRTCClient: videoCallViewModel.webRTCClient)
                                .frame(width: 123.67, height: 166.67)
                                .cornerRadius(10)
                                .shadow(radius: 30)
                                .padding()
                        } else {
                            ZStack {
                                Color.secondary
                                Image(systemName: "video.slash.fill")
                                    .padding()
                            }
                            .frame(width: 123.67, height: 166.67)
                            .cornerRadius(10)
                            .shadow(radius: 30)
                            .padding()
                        }
                    }
                    Spacer()
                }
                VStack {
                    Text(contract.wrappedName)
                        .font(.largeTitle)
                        .padding(.top)
                    if videoCallViewModel.finishingCall {
                        Text("Finishing call...")
                            .padding(.top)
                        Spacer()
                    } else {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: videoCallViewModel.toggleAudio, label: {
                                if videoCallViewModel.isAudioOn {
                                    Image(systemName: "mic.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .shadow(radius: 30)
                                        .padding(.trailing)
                                } else {
                                    Image(systemName: "mic.slash.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .shadow(radius: 30)
                                        .padding(.trailing)
                                }
                            })
                            Button(action: videoCallViewModel.toggleVideo, label: {
                                if videoCallViewModel.isVideoOn {
                                    Image(systemName: "video.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .shadow(radius: 30)
                                        .padding(.trailing)
                                } else {
                                    Image(systemName: "video.slash.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .shadow(radius: 30)
                                        .padding(.trailing)
                                }
                            })
                            Button(action: videoCallViewModel.hangUp, label: {
                                Image(systemName: "phone.down.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.red)
                                    .shadow(radius: 30)
                            })
                            Spacer()
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
        .onAppear(perform: videoCallViewModel.callingViewAppear)
    }
}

struct CallingView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var contract1: Contract = {
        let context = persistence.container.viewContext
        return Contract.createSampleContract1(for: context)
    }()
    
    static var previews: some View {
        CallingView(contract: contract1)
    }
}
