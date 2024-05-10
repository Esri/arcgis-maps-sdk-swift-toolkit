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
***REMOVED***@Binding var text: String
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when the text view's text changes.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ If this is left nil the bound text is updated instead.
***REMOVED***var onTextViewDidChange: ((String) -> Void)? = nil
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when text editing ends.
***REMOVED***var onTextViewDidEndEditing: ((String) -> Void)? = nil
***REMOVED***
***REMOVED***func makeUIView(context: Context) -> UITextView {
***REMOVED******REMOVED***let uiTextView = UITextView()
***REMOVED******REMOVED***uiTextView.delegate = context.coordinator
***REMOVED******REMOVED***return uiTextView
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiTextView: UITextView, context: Context) {
***REMOVED******REMOVED***uiTextView.text = text
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(
***REMOVED******REMOVED******REMOVED***text: $text,
***REMOVED******REMOVED******REMOVED***onTextViewDidChange: onTextViewDidChange,
***REMOVED******REMOVED******REMOVED***onTextViewDidEndEditing: onTextViewDidEndEditing
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***class Coordinator: NSObject, UITextViewDelegate {
***REMOVED******REMOVED******REMOVED***/ The text view's text.
***REMOVED******REMOVED***var text: Binding<String>
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The action to perform when the text view's text changes.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ If this is left nil the bound text is updated instead.
***REMOVED******REMOVED***var onTextViewDidChange: ((String) -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The action to perform when text editing ends.
***REMOVED******REMOVED***var onTextViewDidEndEditing: ((String) -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(
***REMOVED******REMOVED******REMOVED***text: Binding<String>, 
***REMOVED******REMOVED******REMOVED***onTextViewDidChange: ((String) -> Void)? = nil,
***REMOVED******REMOVED******REMOVED***onTextViewDidEndEditing: ((String) -> Void)? = nil
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***self.text = text
***REMOVED******REMOVED******REMOVED***self.onTextViewDidChange = onTextViewDidChange
***REMOVED******REMOVED******REMOVED***self.onTextViewDidEndEditing = onTextViewDidEndEditing
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textViewDidChange(_ textView: UITextView) {
***REMOVED******REMOVED******REMOVED***if let onTextViewDidChange {
***REMOVED******REMOVED******REMOVED******REMOVED***onTextViewDidChange(textView.text)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***text.wrappedValue = textView.text
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textViewDidEndEditing(_ textView: UITextView) {
***REMOVED******REMOVED******REMOVED***onTextViewDidEndEditing?(textView.text)
***REMOVED***
***REMOVED***
***REMOVED***
