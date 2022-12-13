//
//  View+blurEffect.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct UIBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

extension View {
    @ViewBuilder
    func blurEffect(ignoresSafeAreaEdges edges: Edge.Set = []) -> some View {
        if #available(iOS 15.0, *) {
            self.background(.regularMaterial, ignoresSafeAreaEdges: edges)
        } else {
            self.background(
                UIBlur().edgesIgnoringSafeArea(edges)
            )
        }
    }
}
