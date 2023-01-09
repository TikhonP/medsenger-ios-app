//
//  TextView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import UIKit

final class UIKitTextView: UITextView {
    
}

struct UIKitTextViewRepresentable: UIViewRepresentable {
    @Binding private var text: NSAttributedString
    @Binding private var calculatedHeight: CGFloat
    @Binding private var clearText: Bool
    
    private var onEditingChanged: (() -> Void)?
    
    private let isScrollingEnabled: Bool
    
    static let horizontalPadding: CGFloat = 10
    
    init(text: Binding<String>, calculatedHeight: Binding<CGFloat>, clearText: Binding<Bool>, isScrollingEnabled: Bool, onEditingChanged: (() -> Void)? = nil) {
        _text = Binding(
            get: { NSAttributedString(string: text.wrappedValue) },
            set: { newValue in
                DispatchQueue.main.async {
                    text.wrappedValue = newValue.string
                }
            }
        )
        _calculatedHeight = calculatedHeight
        _clearText = clearText
        self.isScrollingEnabled = isScrollingEnabled
        self.onEditingChanged = onEditingChanged
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, calculatedHeight: $calculatedHeight, onEditingChanged: onEditingChanged)
    }
    
    func makeUIView(context: Context) -> UIKitTextView {
        context.coordinator.textView
    }
    
    func updateUIView(_ uiView: UIKitTextView, context: Context) {
        context.coordinator.update(representable: self)
    }
}

extension UIKitTextViewRepresentable {
    final class Coordinator: NSObject {
        internal let textView: UIKitTextView
        
        private var text: Binding<NSAttributedString>
        private var calculatedHeight: Binding<CGFloat>
        private var onEditingChanged: (() -> Void)?
        
        init(text: Binding<NSAttributedString>, calculatedHeight: Binding<CGFloat>, onEditingChanged: (() -> Void)?) {
            textView = UIKitTextView()
            textView.backgroundColor = .clear
            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) 
            textView.contentInset.left = UIKitTextViewRepresentable.horizontalPadding
            textView.contentInset.right = UIKitTextViewRepresentable.horizontalPadding
            textView.attributedText = text.wrappedValue
            textView.font = .preferredFont(forTextStyle: .body)
            textView.adjustsFontForContentSizeCategory = true
            
            self.text = text
            self.calculatedHeight = calculatedHeight
            self.onEditingChanged = onEditingChanged
            
            super.init()
            
            textView.delegate = self
        }
        
        func update(representable: UIKitTextViewRepresentable) {
            textView.isScrollEnabled = representable.isScrollingEnabled
            
            if representable.clearText {
                textView.text = ""
                textView.font = .preferredFont(forTextStyle: .body)
                textView.adjustsFontForContentSizeCategory = true
                DispatchQueue.main.async {
                    representable.clearText = false
                }
            }
            
            recalculateHeight()
        }
        
        private func recalculateHeight() {
            let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude))
            guard calculatedHeight.wrappedValue != newSize.height else { return }
            
            DispatchQueue.main.async { // call in next render cycle.
                self.calculatedHeight.wrappedValue = newSize.height
            }
        }
    }
}

extension UIKitTextViewRepresentable.Coordinator: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        text.wrappedValue = NSAttributedString(attributedString: textView.attributedText)
        recalculateHeight()
        onEditingChanged?()
    }
}
