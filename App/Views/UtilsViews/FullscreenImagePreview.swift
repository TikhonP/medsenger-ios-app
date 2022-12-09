//
//  FullscreenImagePreview.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct FullscreenImagePreview: View {
    let imageData: Data
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ZStack {
            Image(data: imageData)?
                .resizable()
                .scaledToFit()
                .pinchToZoom()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.accentColor)
                            .frame(width: 30)
                            .padding(.trailing)
                            
                        Spacer()
                    }
                }
            })
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .statusBar(hidden: true)
    }
}

//struct FullscreenImagePreview_Previews: PreviewProvider {
//    static var previews: some View {
//        FullscreenImagePreview()
//    }
//}
