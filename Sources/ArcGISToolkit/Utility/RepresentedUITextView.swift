***REMOVED*** Copyright 2024 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***

***REMOVED***/ A represented `UITextView`.
***REMOVED***/
***REMOVED***/ A `UITextView` has noticeably better performance over a SwiftUI `TextField` when dealing with
***REMOVED***/ large input (e.g. thousands of characters).
struct RepresentedUITextView: UIViewRepresentable {
***REMOVED******REMOVED***/ The text view's text.
***REMOVED***private var boundText: Binding<String>?
***REMOVED***
***REMOVED******REMOVED***/ The text initially provided to the view.
***REMOVED***private let initialText: String
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when the text view's text changes.
***REMOVED***private var onTextViewDidChange: ((String) -> Void)? = nil
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when text editing ends.
***REMOVED***private var onTextViewDidEndEditing: ((String) -> Void)? = nil
***REMOVED***
***REMOVED***func makeUIView(context: Context) -> UITextView {
***REMOVED******REMOVED***let uiTextView = UITextView()
***REMOVED******REMOVED***uiTextView.delegate = context.coordinator
***REMOVED******REMOVED***return uiTextView
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiTextView: UITextView, context: Context) {
***REMOVED******REMOVED***if let boundText {
***REMOVED******REMOVED******REMOVED***uiTextView.text = boundText.wrappedValue
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***uiTextView.text = initialText
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***if let boundText {
***REMOVED******REMOVED******REMOVED***Coordinator(
***REMOVED******REMOVED******REMOVED******REMOVED***text: boundText,
***REMOVED******REMOVED******REMOVED******REMOVED***onTextViewDidChange: nil,
***REMOVED******REMOVED******REMOVED******REMOVED***onTextViewDidEndEditing: nil
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Coordinator(
***REMOVED******REMOVED******REMOVED******REMOVED***text: nil,
***REMOVED******REMOVED******REMOVED******REMOVED***onTextViewDidChange: onTextViewDidChange,
***REMOVED******REMOVED******REMOVED******REMOVED***onTextViewDidEndEditing: onTextViewDidEndEditing
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***class Coordinator: NSObject, UITextViewDelegate {
***REMOVED******REMOVED******REMOVED***/ The text view's text.
***REMOVED******REMOVED***var boundText: Binding<String>?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The action to perform when the text view's text changes.
***REMOVED******REMOVED***var onTextViewDidChange: ((String) -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The action to perform when text editing ends.
***REMOVED******REMOVED***var onTextViewDidEndEditing: ((String) -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(
***REMOVED******REMOVED******REMOVED***text: Binding<String>?,
***REMOVED******REMOVED******REMOVED***onTextViewDidChange: ((String) -> Void)? = nil,
***REMOVED******REMOVED******REMOVED***onTextViewDidEndEditing: ((String) -> Void)? = nil
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***self.boundText = text
***REMOVED******REMOVED******REMOVED***self.onTextViewDidChange = onTextViewDidChange
***REMOVED******REMOVED******REMOVED***self.onTextViewDidEndEditing = onTextViewDidEndEditing
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textViewDidChange(_ textView: UITextView) {
***REMOVED******REMOVED******REMOVED***if let boundText {
***REMOVED******REMOVED******REMOVED******REMOVED***boundText.wrappedValue = textView.text
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***onTextViewDidChange?(textView.text)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textViewDidEndEditing(_ textView: UITextView) {
***REMOVED******REMOVED******REMOVED***onTextViewDidEndEditing?(textView.text)
***REMOVED***
***REMOVED***
***REMOVED***

extension RepresentedUITextView {
***REMOVED******REMOVED***/ Creates a `UITextView` bound to the provided text.
***REMOVED******REMOVED***/ - Parameter text: The text to bind to.
***REMOVED***init(text: Binding<String>) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***boundText: text,
***REMOVED******REMOVED******REMOVED***initialText: text.wrappedValue,
***REMOVED******REMOVED******REMOVED***onTextViewDidChange: nil,
***REMOVED******REMOVED******REMOVED***onTextViewDidEndEditing: nil
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `UITextView` initialized with the provided text.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Monitor changes to the text with the `onTextViewDidChange` and `onTextViewDidEndEditing` properties.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - initialText: The view's initial text.
***REMOVED******REMOVED***/   - onTextViewDidChange: The action to perform when the text did change.
***REMOVED******REMOVED***/   - onTextViewDidEndEditing: The action to perform when editing did end.
***REMOVED***init(initialText: String, onTextViewDidChange: ((String) -> Void)?, onTextViewDidEndEditing: ((String) -> Void)? = nil) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***boundText: nil,
***REMOVED******REMOVED******REMOVED***initialText: initialText,
***REMOVED******REMOVED******REMOVED***onTextViewDidChange: onTextViewDidChange,
***REMOVED******REMOVED******REMOVED***onTextViewDidEndEditing: onTextViewDidEndEditing
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
