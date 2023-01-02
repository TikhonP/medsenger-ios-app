//
//  TextView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

/// A SwiftUI TextView implementation that supports both scrolling and auto-sizing layouts
public struct TextView: View {
    
    private let maxHeight: CGFloat = 250
    
    @Environment(\.layoutDirection) private var layoutDirection
    
    @Binding private var text: NSAttributedString
    @Binding private var isEmpty: Bool
    
    @State private var calculatedHeight: CGFloat = 44
    
    private var onEditingChanged: (() -> Void)?
    private var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?
    private var onCommit: (() -> Void)?
    
    var placeholder: String
    var foregroundColor: UIColor = .label
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var multilineTextAlignment: TextAlignment = .leading
    var font: UIFont = .preferredFont(forTextStyle: .body)
    var returnKeyType: UIReturnKeyType?
    var clearsOnInsertion: Bool = false
    var autocorrection: UITextAutocorrectionType = .default
    var truncationMode: NSLineBreakMode = .byTruncatingTail
    var isEditable: Bool = true
    var isSelectable: Bool = true
    var isScrollingEnabled: Bool = true
    var enablesReturnKeyAutomatically: Bool?
    var autoDetectionTypes: UIDataDetectorTypes = []
    var allowRichText: Bool
    
    /// Makes a new TextView with the specified configuration
    /// - Parameters:
    ///   - text: A binding to the text
    ///   - placeholder: A placeholder text
    ///   - shouldEditInRange: A closure that's called before an edit it applied, allowing the consumer to prevent the change
    ///   - onEditingChanged: A closure that's called after an edit has been applied
    ///   - onCommit: If this is provided, the field will automatically lose focus when the return key is pressed
    public init(_ text: Binding<String>,
                placeholder: String = "",
                shouldEditInRange: ((Range<String.Index>, String) -> Bool)? = nil,
                onEditingChanged: (() -> Void)? = nil,
                onCommit: (() -> Void)? = nil
    ) {
        _text = Binding(
            get: { NSAttributedString(string: text.wrappedValue) },
            set: { newValue in
                DispatchQueue.main.async {
                    text.wrappedValue = newValue.string
                }
            }
        )
        
        _isEmpty = Binding(
            get: { text.wrappedValue.isEmpty },
            set: { _ in }
        )
        
        self.placeholder = placeholder
        self.onCommit = onCommit
        self.shouldEditInRange = shouldEditInRange
        self.onEditingChanged = onEditingChanged
        
        allowRichText = false
    }
    
    public var body: some View {
        Representable(
            text: $text,
            calculatedHeight: $calculatedHeight,
            foregroundColor: foregroundColor,
            autocapitalization: autocapitalization,
            multilineTextAlignment: multilineTextAlignment,
            font: font,
            returnKeyType: returnKeyType,
            clearsOnInsertion: clearsOnInsertion,
            autocorrection: autocorrection,
            truncationMode: truncationMode,
            isEditable: isEditable,
            isSelectable: isSelectable,
            isScrollingEnabled: isScrollingEnabled,
            enablesReturnKeyAutomatically: enablesReturnKeyAutomatically,
            autoDetectionTypes: autoDetectionTypes,
            allowsRichText: allowRichText,
            onEditingChanged: onEditingChanged,
            shouldEditInRange: shouldEditInRange,
            onCommit: onCommit
        )
        .frame(height: calculatedHeight < maxHeight ? calculatedHeight : maxHeight)
        .background(
            Text(placeholder)
                .multilineTextAlignment(multilineTextAlignment)
                .foregroundColor(Color(.placeholderText))
                .font(Font(font))
                .padding(.horizontal, 5)
                .opacity(isEmpty ? 1 : 0),
            alignment: .leading
        )
    }
    
}

#if DEBUG
struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(.constant(""))
    }
}
#endif
