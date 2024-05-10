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
    @Binding var text: String
    
    /// The action to perform when the text view's text changes.
    ///
    /// If this is left nil the bound text is updated instead.
    var onTextViewDidChange: ((String) -> Void)? = nil
    
    /// The action to perform when text editing ends.
    var onTextViewDidEndEditing: ((String) -> Void)? = nil
    
    func makeUIView(context: Context) -> UITextView {
        let uiTextView = UITextView()
        uiTextView.delegate = context.coordinator
        return uiTextView
    }
    
    func updateUIView(_ uiTextView: UITextView, context: Context) {
        uiTextView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onTextViewDidChange: onTextViewDidChange, onTextViewDidEndEditing: onTextViewDidEndEditing)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        /// The text view's text.
        var text: Binding<String>
        
        /// The action to perform when the text view's text changes.
        ///
        /// If this is left nil the bound text is updated instead.
        var onTextViewDidChange: ((String) -> Void)?
        
        /// The action to perform when text editing ends.
        var onTextViewDidEndEditing: ((String) -> Void)?
        
        init(text: Binding<String>, onTextViewDidChange: ((String) -> Void)? = nil, onTextViewDidEndEditing: ((String) -> Void)? = nil) {
            self.text = text
            self.onTextViewDidChange = onTextViewDidChange
            self.onTextViewDidEndEditing = onTextViewDidEndEditing
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if let onTextViewDidChange {
                onTextViewDidChange(textView.text)
            } else {
                text.wrappedValue = textView.text
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            onTextViewDidEndEditing?(textView.text)
        }
    }
}
