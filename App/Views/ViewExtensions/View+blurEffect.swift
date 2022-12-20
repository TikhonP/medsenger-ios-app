//
//  View+blurEffect.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

fileprivate struct UIBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

@available(iOS 15.0, *)
fileprivate struct BlurEffectIos15OnlyModifier: ViewModifier {
    let edges: Edge.Set
    
    func body(content: Content) -> some View {
        content.background(.regularMaterial, ignoresSafeAreaEdges: edges)
    }
    
}

extension View {
    @ViewBuilder
    func blurEffect(ignoresSafeAreaEdges edges: Edge.Set = []) -> some View {
        if #available(iOS 15.0, *) {
            self.modifier(BlurEffectIos15OnlyModifier(edges: edges))
        } else {
            self.background(
                UIBlur().edgesIgnoringSafeArea(edges)
            )
        }
    }
}
