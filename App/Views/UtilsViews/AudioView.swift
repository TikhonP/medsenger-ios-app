//
//  AudioView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 12.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct AudioView: View {
    let audioFileUrl: URL
    let color: DSColor
    let width: CGFloat
    let position: Waveform.Position
    
    @State private var waveformImage: DSImage = DSImage()
    @State private var imagePreviewSucceded = true
    
    var body: some View {
        Group {
            if imagePreviewSucceded {
                GeometryReader { reader in
                    image.onAppear{
                        guard waveformImage.size == .zero else { return }
                        let waveformImageDrawer = WaveformImageDrawer()
                        waveformImageDrawer.waveformImage(fromAudioAt: audioFileUrl, with: .init(
                            size: reader.size,
                            style: .striped(.init(color: color, width: width)),
                            position: position
                        )) { image in
                            DispatchQueue.main.async {
                                if let image = image {
                                    waveformImage = image
                                } else {
                                    imagePreviewSucceded = false
                                }
                            }
                        }
                    }
                }
            } else {
                Text("AudioView.failedToPreviewVoiceMessage", comment: "Failed to preview voice message")
            }
        }
    }
    
    private var image: some View {
#if os(macOS)
        Image(nsImage: waveformImage).resizable()
#else
        Image(uiImage: waveformImage).resizable()
#endif
    }
}

struct AudioPlayerView: View {
    let audioFileUrl: URL
    
    @Binding var isPlaying: Bool
    
    /// Progress from 0 to 1
    @Binding var playingAudioProgress: Double
    
    let mainColor: Color
    let progressColor: Color
    let width: CGFloat
    let position: Waveform.Position
    
    init(audioFileUrl: URL, isPlaying: Binding<Bool> = .constant(false), playingAudioProgress: Binding<Double> = .constant(0), mainColor: Color = .black, progressColor: Color = .white, width: CGFloat = 3, position: Waveform.Position = .middle) {
        self.audioFileUrl = audioFileUrl
        _isPlaying = isPlaying
        _playingAudioProgress = playingAudioProgress
        self.mainColor = mainColor
        self.progressColor = progressColor
        self.width = width
        self.position = position
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            AudioView(audioFileUrl: audioFileUrl, color: UIColor(mainColor), width: width, position: position)
            if isPlaying {
                AudioView(audioFileUrl: audioFileUrl, color: UIColor(progressColor), width: width, position: position)
                    .mask(
                        GeometryReader { geometry in
                            HStack {
                                Rectangle().frame(width: geometry.size.width * playingAudioProgress)
                                Spacer()
                            }
                        }
                    )
                    .animation(.default, value: playingAudioProgress)
            }
        }
    }
}

//struct AudioView_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioView()
//    }
//}
