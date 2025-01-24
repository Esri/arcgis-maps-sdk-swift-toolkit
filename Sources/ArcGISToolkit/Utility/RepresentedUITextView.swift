// Copyright 2024 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

/// A represented `UITextView`.
///
/// A `UITextView` has noticeably better performance over a SwiftUI `TextField` when dealing with
/// large input (e.g. thousands of characters).
struct RepresentedUITextView: UIViewRepresentable {
    /// The text view's text.
    private var boundText: Binding<String>?
    
    /// The text initially provided to the view.
    private let initialText: String
    
    /// The action to perform when the text view's text changes.
    private var onTextViewDidChange: ((String) -> Void)? = nil
    
    /// The action to perform when text editing ends.
    private var onTextViewDidEndEditing: ((String) -> Void)? = nil
    
    func makeUIView(context: Context) -> UITextView {
        let uiTextView = UITextView()
        uiTextView.delegate = context.coordinator
#if os(visionOS)
        // The cursor should be white in visionOS not the accent color.
        uiTextView.tintColor = .white
#endif
        
        return uiTextView
    }
    
    func updateUIView(_ uiTextView: UITextView, context: Context) {
        if let boundText {
            uiTextView.text = boundText.wrappedValue
        } else {
            uiTextView.text = initialText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        if let boundText {
            Coordinator(
                text: boundText,
                onTextViewDidChange: nil,
                onTextViewDidEndEditing: nil
            )
        } else {
            Coordinator(
                text: nil,
                onTextViewDidChange: onTextViewDidChange,
                onTextViewDidEndEditing: onTextViewDidEndEditing
            )
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        /// The text view's text.
        var boundText: Binding<String>?
        
        /// The action to perform when the text view's text changes.
        var onTextViewDidChange: ((String) -> Void)?
        
        /// The action to perform when text editing ends.
        var onTextViewDidEndEditing: ((String) -> Void)?
        
        init(
            text: Binding<String>?,
            onTextViewDidChange: ((String) -> Void)? = nil,
            onTextViewDidEndEditing: ((String) -> Void)? = nil
        ) {
            self.boundText = text
            self.onTextViewDidChange = onTextViewDidChange
            self.onTextViewDidEndEditing = onTextViewDidEndEditing
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if let boundText {
                boundText.wrappedValue = textView.text
            } else {
                onTextViewDidChange?(textView.text)
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            onTextViewDidEndEditing?(textView.text)
        }
    }
}

extension RepresentedUITextView {
    /// Creates a `UITextView` bound to the provided text.
    /// - Parameter text: The text to bind to.
    init(text: Binding<String>) {
        self.init(
            boundText: text,
            initialText: text.wrappedValue,
            onTextViewDidChange: nil,
            onTextViewDidEndEditing: nil
        )
    }
    
    /// Creates a `UITextView` initialized with the provided text.
    ///
    /// Monitor changes to the text with the `onTextViewDidChange` and `onTextViewDidEndEditing` properties.
    /// - Parameters:
    ///   - initialText: The view's initial text.
    ///   - onTextViewDidChange: The action to perform when the text did change.
    ///   - onTextViewDidEndEditing: The action to perform when editing did end.
    init(initialText: String, onTextViewDidChange: ((String) -> Void)?, onTextViewDidEndEditing: ((String) -> Void)? = nil) {
        self.init(
            boundText: nil,
            initialText: initialText,
            onTextViewDidChange: onTextViewDidChange,
            onTextViewDidEndEditing: onTextViewDidEndEditing
        )
    }
}
